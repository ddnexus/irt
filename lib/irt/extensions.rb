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

end

class Object
  def object_methods
    methods - self.class.methods
  end
end
