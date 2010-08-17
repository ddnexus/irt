module IRT
  module Irb
    # These methos are available in the main irb context
    module Extensions

      # Short for file history
      # Shows the last lines of the irb file processed
      def fh(lines=IRT.conf.file_lines_on_failure)
        IRT.print_last_lines lines
      end

      # Short for file history
      # Shows all the input lines of the irb session
      def sh
        puts
        puts IRT.session_lines[0..-1]
        puts
      end

      # Short for quit/exit (also x)
      def q
        exit
      end
      alias :x :q

    end
  end
end
