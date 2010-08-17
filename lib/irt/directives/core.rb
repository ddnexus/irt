module IRT
  module Directives
    module Core

      # #: >>
      def open_irb(*)
        IRT.irb_session = true
        IRB.conf[:ECHO] = true
        IRB.conf[:PROMPT][:NULL][:RETURN] = "#:=> %s\n"
        irb = IRB::Irb.new(IRB.CurrentContext.workspace)
        IRB.CurrentContext.main.extend IRT::Irb::Extensions
        catch(:IRB_EXIT) do
          irb.eval_input
        end
        IRT.irb_session = nil
      end

    end
  end
end
