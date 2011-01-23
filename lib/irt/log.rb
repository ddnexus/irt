module IRT
  class Log < Array

    attr_accessor :ignored_commands, :ignored_echo_commands, :non_setting_commands, :tail_size, :status

    def initialize
      @ignored_echo_commands = FileUtils.own_methods
      @ignored_commands = @ignored_echo_commands +
                          IRB::ExtendCommandBundle.instance_methods +
                          %w[ p pp ap y puts print irt irb ]
      @non_setting_commands = @ignored_commands + IRT::Directives.own_methods
      @tail_size = tail_size || 10
      self << FileHunk.new(IRT.irt_file)
      @status = [[File.basename(IRT.irt_file), :file]]
    end

    def add_hunk
      mode = IRB.CurrentContext.irt_mode
      push eval("#{mode.to_s.capitalize + 'Hunk'}.new")
    end

    def add_line(content, line_no)
      last.add_line(content, line_no)
    end

    def self.print_border
      print ' '.log_color.reversed.or('')
    end

    def print(limit=nil) # nil prints all
     hist = dup
     hist.delete_if{|h| h.empty? }
     to_render = hist.reduce([]) do |his, hunk|
                   hu = hunk.dup
                   (his.empty? || his.last.header != hu.header) ? (his << hu) : his.last.concat(hu)
                   his
                 end
      to_print = 0
      if limit.nil? || to_render.map(&:size).inject(:+) <= limit
        to_print = to_render.map(&:size).inject(:+)
        latest_lines = nil
        tails_str = ''
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
        tail_str = ' Tail'
      end
      to_render = to_render.last(to_print)
      puts
      puts "      Virtual Log#{tail_str}      ".log_color.bold.reversed.or('***** IRT Log *****')
      to_render.shift.render(latest_lines)
      to_render.each{|h| h.render }
      puts
    end

    def print_status
      segments = status.map {|name,mode| status_segment(name,mode)}
      puts segments.join(">>".log_color.bold)
    end

    def pop_status
      name, mode = status.pop
      return if mode == :file
      puts "   <<".log_color.bold + status_segment(name, mode)
      puts
    end

    def print_running_file
      puts " Running: #{IRT.irt_file} ".file_color.reversed.bold.or("*** Runing: #{IRT.irt_file} ***")
    end

  private

    def status_segment(name, mode)
      " #{name} ".send("#{mode}_color".to_sym).bold.reversed.or("[#{name}]")
    end
  end
end
