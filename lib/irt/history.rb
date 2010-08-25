module IRT
  class History

    class Line
      attr_reader :origin, :line
      def initialize(line, line_no = nil)
        @line = line.respond_to?(:chomp) ? line.chomp : line
        @origin = IRT.run_status
        @line_no = line_no
      end
      def content
        if from_file?
          lno = IRT.colorize(:yellow, '%3d' % @line_no)
          "#{lno}  #{IRT.colorize(:cyan, @line)}"
        else
         IRT.colorize(:magenta, @line)
        end
      end
      def from_file?
        @origin == :file
      end
    end

    attr_accessor :lines, :ignored_commands, :tail_size, :move_desc

    def initialize(tail_size=10)
      @ignored_commands = %w[ p pp ap y puts irt_help x q ] +
                          (IRT::Directives.methods - Object.methods)
      @lines = []
      @tail_size = tail_size
      @move_desc = true
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
      l = add_line line
      puts l.content
    end

    def add_empty_line
      add_line
      header 'an empty line has been added'
    end

    def insert_desc_line(desc_line)
      return add_history_line(desc_line) unless @move_desc
      rind = 0
      lines.reverse.each_with_index do |l, i|
        if l.from_file? || l.line.empty?
          rind = i
          break
        end
      end
      l = Line.new(desc_line)
      lines.insert(lines.size-rind, l)
      puts l.content
    end

    def print_tail(q=tail_size)
      if lines.empty?
        header 'the history is empty'
      else
        puts
        header "History Tail"
        puts tail(q) * "\n"
      end
    end

    def tail(q=tail_size)
      q = 0 if q > lines.size
      lines[-q..-1].map{|l| l.content }
    end

    def clear_lines
      self.lines = lines.select {|l| l.from_file? }
      header 'session history cleared'
      IRB.CurrentContext.set_last_value nil
    end

    def remove_last_line
      l = lines.last
      if l.from_file?
        header 'last line is a file line'
      else
        lines.pop
        header 'last line has been removed'
        IRB.CurrentContext.set_last_value nil
      end
    end

  end
end
