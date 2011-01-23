require 'stringio'
module Kernel

  def capture
    out = StringIO.new
    $stdout = out
    yield
    return out.string
  ensure
    $stdout = STDOUT
  end

  def irt(bind)
    raise IRT::ArgumentTypeError, "You must pass binding instead of #{bind.class.name} object" unless bind.is_a?(Binding)
    IRT::Directives::Session.send :new_session, :binding, bind
  end

end
