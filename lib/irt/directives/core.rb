module IRT
  module Directives
    module Core

      # Opens an interactive session at the line it is called
      # eventually executing command
      def open_session(command=nil)
        IRT.run_status = :session
        IRB.conf[:ECHO] = true
        file_context = IRB.CurrentContext
        irb = IRB::Irb.new(file_context.workspace)
        irb.context.set_last_value file_context.last_value
        IRB.conf[:MAIN_CONTEXT] = irb.context
        IRT.history.print_tail if IRT.show_tail_on_open_session
        IRT.skip_result_output = false
        if command
          puts IRB.conf[:PROMPT][:IRT][:PROMPT_I] + command
          irb.context.workspace.evaluate(irb.context, command)
        end
        catch(:IRB_EXIT) do
          irb.eval_input
        end
        IRB.conf[:MAIN_CONTEXT] = file_context
        IRT.run_status = :file
      end
      alias :irt :open_session

      # restart IRT
      def r!
        IRB.irb_at_exit
        puts IRT.colorize(:yellow, "Restarting IRT: `#{ENV['IRT_COMMAND']}`")
        puts "=== Running file #{ENV["IRT_FILE"]} ==="
        exec ENV["IRT_COMMAND"]
      end

      # Short for quit/exit
      def x
        exit
      end
      alias :q :x

      def irt_at_exit(&block)
        IRB.conf[:AT_EXIT] << proc(&block)
      end

    end
  end
end
