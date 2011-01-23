require 'irb'
require 'irb/context'
require 'fileutils'

require 'irt/commands/log'
require 'irt/commands/test'
require 'irt/commands/system'
require 'irt/commands/misc'
require 'irt/commands/help'

module IRB #:nodoc:

  module ExtendCommandBundle

    include IRT::Commands::Log
    include IRT::Commands::Test
    include IRT::Commands::System
    include IRT::Commands::Misc
    include IRT::Commands::Help
    include FileUtils

    alias_method :xx, :abort
    alias_method :qq, :abort

    def irt(obj=nil)
      mode = case obj
             when nil
               :interactive
             when Binding
               :binding
             else
               :inspect
             end
      raise IRT::SessionModeError, "You cannot pass binding in #{mode} mode" if mode == :binding
      raise IRT::SessionModeError, "You cannot open another interactive session in #{mode} mode" \
        if mode == :interactive && IRB.CurrentContext.irt_mode != :file
      IRT::Directives::Session.send :new_session, mode, obj
    end
    alias_method :open_session, :irt # legacy method
    alias_method :irb, :irt

    %w[p y pp ap].each do |m|
      define_method(m) do |*args|
        args = [IRB.CurrentContext.last_value] if args.empty?
        super *args
      end
    end

    def method_missing(method, *args, &block)
      IRB.conf[:MAIN_CONTEXT] && IRB.conf[:MAIN_CONTEXT].irt_mode == :file && IRT::Directives.respond_to?(method) ?
        IRT::Directives.send(method, *args, &block) :
        super
    end

  end

  class Context

    attr_accessor :parent_context, :current_line, :binding_file, :binding_line_no, :backtrace_map
    attr_reader :current_line_no, :last_line_no
    attr_writer :irt_mode

    def file_line_pointers
      file = line = nil
      c = self
      until file && line
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
        IRT::Directives::Session.send(:new_session, :interactive) if irt_mode == :file
        @exception_raised = false
      end
      log_file_line(line_no) if irt_mode == :file
      begin
        # ri arg to string
        if m = line.match(/^(\s*ri[ \t]+)(.+)$/)
          pre, to_search = m.captures
          line = "#{pre}#{to_search.inspect}" unless to_search.match(/^('|").+\1$/)
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
        print "\e[31m" if Colorer.color?
        raise
      else
        log_session_line(line, line_no) unless irt_mode == :file
      end
    end

    %w[prompt_i prompt_s prompt_c prompt_n].each do |m|
      define_method(m) do
        pr = instance_variable_get("@#{m}")
        col_pr = pr.send "#{irt_mode}_color"
        # workaround for Readline bug see http://www.ruby-forum.com/topic/213807
        if IRT.fix_readline_prompt
          col_pr.gsub(/^(.*)#{pr}(.*)$/, "\001\\1\002#{pr}\001\\2\002")
        else
          col_pr
        end
      end
    end

    def return_format(color=:actual_color, ignored=false)
      ret = ignored ? @return_format.sub(/=/,'#') : @return_format
      ret.send color
    end

private

    def process_exception(e)
      return if IRT.debug
      bktr = e.backtrace.reject {|m| File.expand_path(m).match(/^#{IRT.lib_path}/) }
      e.set_backtrace( e.class.name.match(/^IRT::/) ? bktr : map_backtrace(bktr) )
    end

    def map_backtrace(bktr)
      @backtrace_map = {}
      mapped_bktr = []
      reverted_error_colors = 'xxx'.error_color.match(/^(.*)xxx(.*)$/).captures.reverse
      index_format = sprintf '%s%%s%s', *reverted_error_colors
      bktr.each_with_index do |m, i|
        unless i + 1 > back_trace_limit || m.match(/^\(.*\)/) || workspace.filter_backtrace(m).nil?
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
        printf return_format(:ignored_color,false), value.inspect
      else
        printf return_format(:ignored_color,false), value
      end
    end
  end

  def IRB.irb_exit(irb, ret)
    IRT.irt_exit
    throw :IRB_EXIT, ret
  end

end
