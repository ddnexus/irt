require 'stringio'
module Kernel

  # copied from ActiveRecord 3.1 because of conflicting name with previous IRT implementation
  # modified in the argument default in order to be used by both AR and IRT
  def capture(stream=:stdout)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end
  alias :silence :capture

  def irt(bind)
    raise IRT::ArgumentTypeError, "You must pass binding instead of #{bind.class.name} object" unless bind.is_a?(Binding)
    IRT.start
    IRT::Session.enter :binding, bind
  end

end
