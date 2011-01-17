require 'irt/directives/test'
require 'irt/directives/session'

module IRT
  module Directives

    extend self
    extend Test
    extend Session

    def irt_at_exit(&block)
      IRB.conf[:AT_EXIT] << proc(&block)
    end

  end
end
