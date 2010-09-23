module IRT
  module Directives
    module Core

      # Opens an interactive session at the line it is called
      # eventually executing command
      def open_session(command=nil)
        return unless IRT.run_status == :file
        IRT.run_status = :session
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
        exit if IRT.run_status == :full_exit
        IRB.conf[:MAIN_CONTEXT] = file_context
        IRT.run_status = :file
        IRT.history.add_header_line file_context.io.file_name
      end
      alias :irt :open_session

      # Evaluate a file as it were inserted at that line
      # a relative file_path is considered to be relative to the including file
      # i.e. '../file_in_the_same_dir.irt'
      def eval_file(file_path)
        old_status = IRT.run_status
        IRT.run_status = :file
        file_context = IRB.CurrentContext
        old_io = file_context.io
        io = IRB::FileInputMethod.new File.expand_path(file_path, old_io.io.path)
        irb = IRB::Irb.new(file_context.workspace, io)
        irb.context.set_last_value file_context.last_value
        IRB.conf[:MAIN_CONTEXT] = irb.context
        catch(:IRB_EXIT) do
          irb.eval_input
        end
        exit if IRT.run_status == :full_exit
        IRB.conf[:MAIN_CONTEXT] = file_context
        IRB.CurrentContext.io = old_io
        IRT.run_status = old_status
        IRT.history.add_header_line old_io.file_name
      end
      alias :insert_file :eval_file

      # restart IRT
      def r!
        IRB.irb_at_exit
        puts
        puts " Restarting IRT: `#{ENV['IRT_COMMAND']}` ".restart
        puts
        IRT.puts_running ENV["IRT_FILE"]
        exec ENV["IRT_COMMAND"]
      end
      alias :rr :r!

      def irt_at_exit(&block)
        IRB.conf[:AT_EXIT] << proc(&block)
      end

      def x!
        IRT.run_status = :full_exit
       exit
      end
      alias :q! :x!

    end
  end
end
