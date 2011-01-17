module IRT
  module Directives
    module Session

      extend self

      def irt(bind)
        raise NotImplementedError, "You must pass binding" unless bind.is_a?(Binding)
        new_session :binding, bind
      end

      # Evaluate a file as it were inserted at that line
      # a relative file_path is considered to be relative to the including file
      # i.e. '../file_in_the_same_dir.irt'
      def eval_file(file_path)
        parent_context = IRB.CurrentContext
        new_io = IRB::FileInputMethod.new(File.expand_path(file_path, parent_context.io.file_name))
        new_irb = IRB::Irb.new(parent_context.workspace, new_io)
        new_irb.context.irb_name = File.basename(new_io.file_name)
        new_irb.context.irb_path = new_io.file_name
        eval(new_irb.context, :file)
        IRT.irt_exit
      end
      alias_method :insert_file, :eval_file

    private

      def new_session(mode, obj=nil)
        IRT.log.print if IRT.tail_on_irt
        ws = obj ? IRB::WorkSpace.new(obj) : IRB.CurrentContext.workspace
        new_irb = IRB::Irb.new(ws)
        IRT.session_no += 1
        main_name = mode == :inspect ?
                      IRB.CurrentContext.current_line.match(/^\s*(?:irb|irt|irt_inspect)\s+(.*)$/).captures[0].strip :
                      new_irb.context.workspace.main.to_s
        main_name = main_name[0..30] + '...' if main_name.size > 30
        new_irb.context.irb_name = "irt##{IRT.session_no}(#{main_name})"
        new_irb.context.irb_path = "(irt##{IRT.session_no})"
        set_binding_file_pointers(new_irb.context) if mode == :binding
        eval(new_irb.context, mode)
      end

      def eval(new_context, mode)
        new_context.parent_context = IRB.CurrentContext
        new_context.set_last_value( IRB.CurrentContext.last_value ) unless (mode == :inspect || mode == :binding)
        new_context.irt_mode = mode
        IRB.conf[:MAIN_CONTEXT] = new_context
        IRT.log.add_hunk
        IRT.log.status << [new_context.irb_name, mode]
        IRT.log.print_status unless mode == :file
        catch(:IRB_EXIT) { new_context.irb.eval_input }
      end

      # used for open the last file for editing
      def set_binding_file_pointers(context)
        caller.each do |c|
          file, line = c.sub(/:in .*$/,'').split(':', 2)
          next if File.expand_path(file).match(/^#{IRT.lib_path}/) # exclude irt internal callers
          context.binding_file = file
          context.binding_line_no = line
          break
        end
      end

      def IRT.irt_exit
        exiting_context = IRB.conf[:MAIN_CONTEXT]
        resuming_context = exiting_context.parent_context
        exiting_mode = exiting_context.irt_mode
        resuming_context.set_last_value( exiting_context.last_value ) \
          unless (exiting_mode == :inspect || exiting_mode == :binding)
        IRT.log.pop_status
        IRT.log.print_status unless resuming_context.irt_mode == :file
        IRB.conf[:MAIN_CONTEXT] = resuming_context
        IRT.log.add_hunk
      end

    end
  end
end
