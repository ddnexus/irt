module IRT
  module Commands
    module Log

      def log(limit=nil)
        ensure_session
        IRT.log.print limit || IRT.log.tail_size
        IRT.log.print_status
      end
      alias_method :l, :log

      def full_log
        ensure_session
        IRT.log.print
        IRT.log.print_status
      end
      alias_method :ll, :full_log

      def status
        ensure_session
        IRT.log.print_status
      end
      alias_method :ss, :status

      def print_lines
        ensure_session
        lines_str = IRT.log.last.lines_str
        return if lines_str.empty?
        puts
        puts lines_str
        puts
      end
      alias_method :pl, :print_lines

      def print_all_lines
        ensure_session
        lines = []
        IRT.log.reject{|h| h.class == IRT::Log::FileHunk }.each do |h|
          ls = h.lines_str
          lines << ls unless ls.empty?
        end
        unless lines.empty?
          puts
          puts lines.join("\n\n")
          puts
        end
      end
      alias_method :pll, :print_all_lines

    end
  end
end
