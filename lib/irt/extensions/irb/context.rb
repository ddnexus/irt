require 'irb/context'

module IRB
  class Context #:nodoc:

    attr_accessor :parent_context, :current_line, :binding_file, :binding_line_no, :backtrace_map
    attr_reader :current_line_no, :last_line_no
    attr_writer :irt_mode, :return_ignored_echo_format

    def file_line_pointers
      file = line = nil
      c = self
      until file
        case c.irt_mode
        when :binding
          file = c.binding_file
          line = c.binding_line_no
        when :file
          file = c.irb_path
          line = c.last_line_no
        end
        c = c.parent_context
      end
      [file, line]
    end

    def irt_mode
      @irt_mode ||= :file
    end

    alias_method :evaluate_and_set_last_value, :evaluate
    def evaluate(line, line_no)
      @current_line = line
      @current_line_no = line_no + line.chomp.count("\n")
      if @exception_raised
        IRT::Session.enter(:interactive) if irt_mode == :file
        @exception_raised = false
      end
      log_file_line(line_no) if irt_mode == :file
      begin
        # ri arg to string
        if m = line.match(/^(\s*ri[ \t]+)(.+)$/)
          pre, to_search = m.captures
          line = "#{pre}#{to_search.inspect}" unless to_search.match(/^('|").+\1$/)
        else
          IRT::Commands::Ri.reset_choices_map
        end
        # skip setting last_value for non_setting_commands
        if line =~ /^\s*(#{IRT.log.non_setting_commands * '|'})\b/
          self.echo = false
          res = @workspace.evaluate(self, line, irb_path, line_no)
          if line =~ /^\s*(#{IRT.log.ignored_echo_commands * '|'})\b/
            output_ignored_echo_value(res)
          end
        else
          self.echo = irt_mode == :file ? false : true
          evaluate_and_set_last_value(line, line_no)
        end
      rescue Exception => e
        @exception_raised = true
        process_exception(e)
        print "\e[31m" if Dye.color?
        raise
      else
        log_session_line(line, line_no) unless irt_mode == :file
      end
    end

    %w[prompt_i prompt_s prompt_c prompt_n].each do |m|
      define_method(m) do
        pr = instance_variable_get("@#{m}")
        col_pr = IRT.dye pr, "#{irt_mode}_color".to_sym
        # workaround for Readline bug see http://www.ruby-forum.com/topic/213807
        if IRT.fix_readline_prompt
          col_pr.gsub(/^(.*)#{pr}(.*)$/, "\001\\1\002#{pr}\001\\2\002")
        else
          col_pr
        end
      end
    end

    def return_format
      IRT.dye @return_format, :actual_color
    end

    def return_ignored_echo_format
      IRT.dye @return_ignored_echo_format, :ignored_color
    end

    alias_method :original_prompt_mode, :prompt_mode=
    def prompt_mode=(mode)
      original_prompt_mode(mode)
      @return_ignored_echo_format = IRB.conf[:PROMPT][mode][:RETURN_I] || "   #> %s\n"
    end

private

    def process_exception(e)
      bktr = e.backtrace.reject do |m|
               workspace.filter_backtrace(m).nil? || !IRT.debug && File.expand_path(m).match(/^#{IRT.lib_path}/)
             end
      e.set_backtrace( e.class.name.match(/^IRT::/) ? bktr : map_backtrace(bktr) )
    end

    def map_backtrace(bktr)
      @backtrace_map = {}
      mapped_bktr = []
      reverted_error_colors = IRT.dye('xxx', :error_color).match(/^(.*)xxx(.*)$/).captures.reverse
      index_format = sprintf '%s%%s%s', *reverted_error_colors
      bktr.each_with_index do |m, i|
        unless i + 1 > back_trace_limit || m.match(/^\(.*\)/)
          @backtrace_map[i] = m.split(':')[0..1]
          index = sprintf index_format, " [#{i}]"
        end
        mapped_bktr << "#{m}#{index}"
      end
      mapped_bktr
    end

    def log_file_line(line_no)
      log_lines(@current_line, line_no)
    end

    def log_session_line(line, line_no)
      # @current_line might get changed by the IRT::Commands::Test methods,
      # while the line arg is the original command
      segments = line.chomp.split("\n", -1)
      last_segment = segments.pop
      if last_segment.match(/^[ \t]*(#{IRT::Commands::Test.own_methods * '|'})\b/)
        log_lines segments.map{|s| "#{s}\n"}.join, line_no
        @last_line_no = @last_line_no ? @last_line_no + 1 : line_no
        @current_line.each_line do |l|
          IRT.log.add_line l, @last_line_no
        end
      else
        log_lines(@current_line, line_no)
      end
    end

    def log_lines(str, line_no)
      i = -1
      str.each_line do |l|
        @last_line_no = line_no + i+=1
        IRT.log.add_line l, @last_line_no
      end
    end

    def output_ignored_echo_value(value)
      if inspect?
        printf return_ignored_echo_format, value.inspect
      else
        printf return_ignored_echo_format, value
      end
    end

  end
end
