module IRT
  class Log < Array

    attr_accessor :ignored_commands, :ignored_echo_commands, :non_setting_commands, :tail_size
    attr_reader :status

    def initialize
      @ignored_echo_commands = FileUtils.own_methods + [:_]
      @ignored_echo_commands += IRT::Commands::Rails.own_methods if defined?(IRT::Commands::Rails)
      @ignored_echo_commands = @ignored_echo_commands.map(&:to_sym)
      @ignored_commands = @ignored_echo_commands +
                          IRB::ExtendCommandBundle.instance_methods +
                          [ :p, :pp, :ap, :y, :puts, :print, :irt, :irb ]
      @ignored_commands = @ignored_commands.map(&:to_sym)
      @non_setting_commands = @ignored_commands + IRT::Directives.own_methods
      @non_setting_commands = @non_setting_commands.map(&:to_sym)
      @tail_size = tail_size || 10
      self << FileHunk.new(IRT.irt_file)
      @status = [[IRT.irt_file.basename, :file]]
    end

    def add_hunk
      mode = IRB.CurrentContext.irt_mode
      push eval("#{mode.to_s.capitalize + 'Hunk'}.new")
    end

    def add_line(content, line_no)
      last.add_line(content, line_no)
    end

    def self.print_border
      print IRT.dye(' ','', :log_color, :reversed)
    end

    def print(limit=nil) # nil prints all
      hist = dup
      hist.delete_if{|h| h.empty? }
      to_render = hist.reduce([]) do |his, hunk|
                    hu = hunk.dup
                    (his.empty? || his.last.header != hu.header) ? (his << hu) : his.last.concat(hu)
                    his
                  end
      if to_render.empty?
        print_header '(empty)'
      else
        to_print = 0
        if limit.nil? || to_render.map(&:size).inject(:+) <= limit
          to_print = to_render.map(&:size).inject(:+)
          latest_lines = nil
          print_header
        else
          rest = limit
          to_render.reverse.each do |h|
            to_print += 1
            if rest > h.size
              rest = rest - h.size
              next
            else
              latest_lines = rest
              break
            end
          end
          print_header '(tail)'
        end
        to_render = to_render.last(to_print)
        to_render.shift.render(latest_lines)
        to_render.each{|h| h.render }
      end
      puts
    end

    def print_status
      segments = status.map {|name,mode| status_segment(name,mode)}
      puts segments.join(IRT.dye(">>", :log_color, :bold))
    end

    def pop_status
      name, mode = status.pop
      return if mode == :file
      puts IRT.dye("   <<", :log_color, :bold) + status_segment(name, mode)
      puts
    end

    def print_running_file
      run_str = "Running: #{IRT.irt_file}"
      puts IRT.dye(" #{run_str} ", "*** #{run_str} ***", :file_color, :bold, :reversed)
    end

  private

    def print_header(tail_str='')
      puts
      log_head = "Virtual Log#{' '+ tail_str unless tail_str.empty?}"
      puts IRT.dye("      #{log_head}      ", '***** #{log_head} *****', :log_color, :bold, :reversed)
    end

    def status_segment(name, mode)
      IRT.dye(" #{name} ", "[#{name}]", "#{mode}_color".to_sym, :bold, :reversed)
    end
  end
end
