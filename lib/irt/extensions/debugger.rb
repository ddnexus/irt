module IRB

  def self.start_session(bind)
    IRT.start
    IRT::Session.enter :binding, bind
  end

  class Context
    alias_method :evaluate_without_debugger, :evaluate
    def evaluate(line, line_no)
      $rdebug_irb_statements = line
      evaluate_without_debugger line, line_no
    end
  end

end

module Kernel
  alias_method :original_irt, :irt
  def irt(bind=nil)
    IRT.start
    IRT::Commands::Core.irt(bind)
  end
end

module IRT
  module Session

    private

    def set_binding_file_pointers(context)
      context.binding_file = Debugger.current_context.frame_file
      context.binding_line_no = Debugger.current_context.frame_line
    end

  end
end


