module IRT
  class History

    class Line
      attr_reader :origin
      def initialize(line, line_no = nil)
        @line = line.respond_to?(:chomp) ? line.chomp : line
        @origin = IRT.run_status
        @line_no = line_no
      end
      def content
        if @origin == :file
          lno = IRT.colorize(:yellow, '%3d' % @line_no)
          "#{lno}  #{IRT.colorize(:cyan, @line)}"
        else
         IRT.colorize(:magenta, @line)
        end
      end
    end

    attr_accessor :lines, :ignored_commands, :tails_size

    def initialize(tails_size=10)
      @ignored_commands = %w[ p pp ap y _ puts irt h hrl x q exit irt_help add_test add_desc add_comment]
      @lines = []
      @tails_size = tails_size
    end

    def header(message)
      puts IRT.colorize(:yellow, "--- #{message} ---")
    end

    def add_line(line='', line_no=nil)
      l = Line.new(line, line_no)
      self.lines << l
      l
    end

    def add_history_line(line)
      IRT.skip_result_output = true
      l = add_line line
      puts l.content
    end

    def print_tail(q=tails_size)
      IRT.skip_result_output = true
      if lines.empty?
        header 'History empty'
      else
        puts
        header "History tail"
        puts tail(q) * "\n"
      end
    end

    def tail(q=tails_size)
      q = 0 if q > lines.size
      lines[-q..-1].map{|l| l.content }
    end

    def clear_lines
      IRT.skip_result_output = true
      self.lines = []
      header 'History Cleared'
    end

    def remove_last_line
     # IRT.skip_result_output = true
      l = lines.last
      if l.origin == :file
        header 'last line is a file line'
      else
        lines.pop
        header 'last line removed'
      end
      IRB.CurrentContext.set_last_value nil
    end

  end
end
