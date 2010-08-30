module IRT
  class History

    class Line
      def initialize(content)
        @content = content.respond_to?(:chomp) ? content.chomp : content
      end
      def render
        raise NotImplementedError
      end
    end

    class EmptyLine
      def render; '' end
    end

    class FileLine < Line
      attr_reader :file_name
      def initialize(content, line_no, file_name)
        super content
        @line_no = line_no
        @file_name = file_name
      end
      def render
        lno = ('%3d ' % @line_no).header
        "#{lno} #{@content.file_line}"
      end
    end

    class SessionLine < Line
      def render
        @content.session_line
      end
    end

    class HeaderLine < Line
      def render
        " === #{@content} === ".header
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
      puts "--- #{message} ---".message
    end

    def add_file_line(*args)
      self.lines << FileLine.new(*args)
    end

    def add_header_line(file_name)
      ll = lines.last
      return if ll.is_a?(FileLine) && ll.file_name == file_name
      self.lines << HeaderLine.new(file_name)
    end

    def add_session_line(line, output=true)
      l = SessionLine.new line
      self.lines << l
      puts l.render if output
    end

    def add_empty_line
      self.lines << EmptyLine.new
      message 'an empty line has been added'
    end

    def insert_desc_line(desc_line)
      return add_session_line(desc_line) unless @move_desc
      rind = 0
      lines.reverse.each_with_index do |l, i|
        if l.is_a?(FileLine) || l.is_a?(EmptyLine)
          rind = i
          break
        end
      end
      l = SessionLine.new(desc_line)
      lines.insert(lines.size-rind, l)
      puts l.render
    end

    def print_tail(q=tail_size)
      if lines.empty?
        message 'the history is empty'
      else
        puts
        q = 0 if q > lines.size
        tail = lines[-q..-1].map{|l| l.render }
        rind = lines[0..-q].rindex { |l| l.is_a?(HeaderLine) }
        last_header = lines[rind].render
        puts last_header unless lines[-q].is_a?(HeaderLine)
        puts tail * "\n"
      end
    end

    def clear_lines
      self.lines = lines.select {|l| l.is_a?(FileLine) }
      message 'session history cleared'
      IRB.CurrentContext.set_last_value nil
    end

    def remove_last_line
      l = lines.last
      if l.is_a?(FileLine)
        message 'last line is a file line'
      else
        lines.pop
        message 'last line has been removed'
        IRB.CurrentContext.set_last_value nil
      end
    end

  end
end
