module IRT
  class Log

    class Hunk < Array

      attr_reader :header, :color

      def initialize(header)
        @header = header
      end

      def add_line(content, line_no)
        self << [content.chomp, line_no]
      end

      def render(wanted=nil)
        return unless size > 0
        Log.print_border
        render_header
        wanted ||= size
        last(wanted).each do |content, line_no|
          Log.print_border
          render_line(content, line_no)
        end
      end

      def lines_str
        map{|content, line_no| content }.join("\n")
      end

      def last_line_no
        last && last[1]
      end

      def header_name
        @header
      end

      def render_header
        puts IRT.dye("     #{header_name}     ",  "***** #{header_name} *****", color, :bold, :reversed)
      end

      def render_line(content, line_no)
        lcontent = IRT.dye content, color
        lno = IRT.dye(('%3d ' % line_no), color, :reversed)
        puts "#{lno} #{lcontent}"
      end

      def inspect
        %(<#{self.class.name} #{header_name}>)
      end

    end


    class FileHunk < Hunk

      def initialize(header=nil)
        @color = :file_color
        @header = header || IRB.CurrentContext.irb_path
      end

      def header_name
        File.basename(@header)
      end

    end


    class InteractiveHunk < Hunk

      def initialize
        @color = :interactive_color
        @header = IRB.CurrentContext.irb_name
      end

    end


    class InspectHunk < InteractiveHunk

      def initialize
        super
        @color = :inspect_color
      end

      def add_line(content, line_no)
      end

    end

    class BindingHunk < InteractiveHunk

      def initialize
        super
        @color = :binding_color
      end

      def add_line(content, line_no)
      end

    end

  end
end
