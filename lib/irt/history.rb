module IRT
  class History

    class Line
      attr_reader :origin, :line
      def initialize(line, line_no = nil, origin=IRT.run_status)
        @line = line.respond_to?(:chomp) ? line.chomp : line
        @origin = origin
        @line_no = line_no
      end
      def content
        case @origin
        when :file
          lno = IRT.colorize(:yellow, '%3d' % @line_no)
          "#{lno}  #{IRT.colorize(:cyan, @line)}"
        when :session
          IRT.colorize(:magenta, @line)
        when :header
          IRT.colorize(:yellow, @line)
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

    def message(message)
      puts IRT.colorize(:yellow, "--- #{message} ---")
    end

    def add_line(line='', line_no=nil)
      l = Line.new(line, line_no)
      self.lines << l
      l
    end

    def add_header_line(file)
      self.lines << Line.new("=== #{file} ===", nil, :header)
    end

    def add_history_line(line)
      l = add_line line
      puts l.content
    end

    def add_empty_line
      add_line
      message 'an empty line has been added'
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
        message 'the history is empty'
      else
        puts
        q = 0 if q > lines.size
        tail = lines[-q..-1].map{|l| l.content }
        rind = lines[0..-q].rindex { |l| l.origin == :header }
        last_header = lines[rind].content
        puts last_header unless lines[-q].origin == :header
        puts tail * "\n"
      end
    end

    def clear_lines
      self.lines = lines.select {|l| l.from_file? }
      message 'session history cleared'
      IRB.CurrentContext.set_last_value nil
    end

    def remove_last_line
      l = lines.last
      if l.from_file?
        message 'last line is a file line'
      else
        lines.pop
        message 'last line has been removed'
        IRB.CurrentContext.set_last_value nil
      end
    end

  end
end
