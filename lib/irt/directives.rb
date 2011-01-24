require 'irt/directives/test'

module IRT
  module Directives

    extend self
    extend Test

    # Evaluate a file as it were inserted at that line
    # a relative file_path is considered to be relative to the including file
    # i.e. '../file_in_the_same_dir.irt'
    def eval_file(file_path)
      parent_context = IRB.CurrentContext
      new_io = IRB::FileInputMethod.new(File.expand_path(file_path, parent_context.io.file_name))
      new_irb = IRB::Irb.new(parent_context.workspace, new_io)
      new_irb.context.irb_name = File.basename(new_io.file_name)
      new_irb.context.irb_path = new_io.file_name
      IRT::Session.eval_input(new_irb.context, :file)
      IRT::Session.exit
    end
    alias_method :insert_file, :eval_file

    def irt_at_exit(&block)
      IRB.conf[:AT_EXIT] << proc(&block)
    end

  end
end
