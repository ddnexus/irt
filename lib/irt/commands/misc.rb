module IRT
  module Commands
    module Misc

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
        IRT::Directives::Session.send :new_session, to_mode, obj
      end
      alias_method :open_session, :irt # legacy method

      %w[p y pp ap].each do |m|
        define_method(m) do |*args|
          args = [context.last_value] if args.empty?
          super *args
        end
      end

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
        exec ENV["IRT_COMMAND"]
      end
      alias_method :rr, :rerun

    end
  end
end
