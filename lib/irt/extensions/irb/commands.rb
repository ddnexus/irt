require 'irt/commands/log'
require 'irt/commands/test'
require 'irt/commands/system'
require 'irt/commands/core'
require 'irt/commands/help'
require 'irt/commands/ri'
require 'fileutils'

module IRB
  module ExtendCommandBundle #:nodoc:

    include IRT::Commands::Log
    include IRT::Commands::Test
    include IRT::Commands::System
    include IRT::Commands::Core
    include IRT::Commands::Help
    include IRT::Commands::Ri
    include FileUtils

    alias_method :x, :irb_exit
    alias_method :q, :irb_exit
    alias_method :xx, :abort
    alias_method :qq, :abort
    alias_method :irb, :irt

    def method_missing(method, *args, &block)
      IRB.conf[:MAIN_CONTEXT] && IRB.conf[:MAIN_CONTEXT].irt_mode == :file && IRT::Directives.respond_to?(method) ?
        IRT::Directives.send(method, *args, &block) :
        super
    end

  private

    def ensure_session
      if context.irt_mode == :file
        m = caller[0].match(/`(\w*)'$/).captures[0]
        raise IRT::SessionModeError, "You cannot use the :#{m} method in #{context.irt_mode} mode."
      end
    end

  end
end
