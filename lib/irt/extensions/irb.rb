require 'irb'
require 'irt/extensions/irb/context'
require 'irt/extensions/irb/commands'

module IRB #:nodoc:

  def IRB.irb_exit(irb, ret)
    IRT.irt_exit
    throw :IRB_EXIT, ret
  end

end
