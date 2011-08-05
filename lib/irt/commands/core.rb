module IRT
  module Commands
    module Core

      def irt(obj=nil)
        irt_mode = context.irt_mode
        to_mode = case obj
                  when nil
                    :interactive
                  when Binding
                    :binding
                  else
                    :inspect
                  end
        raise IRT::SessionModeError, "You cannot pass binding in #{irt_mode} mode" \
          if to_mode == :binding && (irt_mode == :binding || caller[0].match(/^\(/))
        raise IRT::SessionModeError, "You cannot open another interactive session in #{irt_mode} mode" \
          if to_mode == :interactive && irt_mode != :file
        IRT::Session.enter to_mode, obj
      end
      alias_method :open_session, :irt # legacy method

      def vdiff(a,b)
        ensure_session
        puts IRT::Differ.new(a,b, :value, {:a_marker => 'a',
                                           :b_marker => 'b',
                                           :a_label => '',
                                           :b_label => ''}).output
      end
      alias_method :vd, :vdiff

      # rerun the same shell command
      def restart
        ensure_session
        ensure_cli
        IRB.irb_at_exit
        str = "Restarting: `#{ENV['IRT_COMMAND']}`"
        puts
        puts IRT.dye(" #{str} ", "*** #{str} ***", :error_color, :bold, :reversed)
        puts
        exec ENV["IRT_COMMAND"]
      end
      alias_method :rs, :restart

      def rerun
        ensure_session
        Directives::Test.test_summary
        Directives::Test.reset_variables
        IRT::Session.run_file
      end
      alias_method :rr, :rerun

      def run(file_path)
        ensure_session
        IRT::Session.run_file file_path
      end

      def sh(*args)
        system *args
      end

      def pager(arg=nil, &block)
        ensure_session
        raise ArgumentError, "You must pass an arguent or a block" if arg.nil? && block.nil?
        # in case of a block we will just capture in memory its whole output to stdout
        output = arg || capture(:stdout, &block)
        IO.popen(IRT.pager_command, 'w') do |io|
          io.puts output
        end
      end
      alias_method :pg, :pager

    end
  end
end
