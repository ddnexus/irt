module IRT
  module Commands
    module Misc

      def vdiff(a,b)
        puts IRT::Differ.new(a,b, :value, {:a_marker => 'a',
                                           :b_marker => 'b',
                                           :a_label => '',
                                           :b_label => ''}).output
      end
      alias_method :vd, :vdiff

      # rerun the same file
      def rerun
        IRB.irb_at_exit
        str = "Rerunning: `#{ENV['IRT_COMMAND']}`"
        puts
        puts " #{str} ".error_color.bold.reversed.or("*** #{str} ***")
        puts
        IRT.log.print_running_file
        exec ENV["IRT_COMMAND"]
      end
      alias_method :rr, :rerun

      def x
        exit
      end
      alias_method :q, :x

    end
  end
end
