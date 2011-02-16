class ActiveSupport::BufferedLogger

  alias_method :original_add, :add

  def add(*args)
    message = original_add(*args)
    # no inline log when in rails server and not interactive mode
    return message if IRB.CurrentContext.nil? || IRT.rails_server && IRB.CurrentContext.irt_mode != :interactive
    if IRT.rails_log
      if IRT.dye_rails_log
        plain_message = Dye.strip_ansi(message).chomp
        irt_message = IRT.dye(plain_message, :log_color) + "\n"
      end
      puts irt_message || message
    end
    message
  end

end

module Kernel

  alias_method :original_irt, :irt
  def irt(bind)
    IRT.send(:rails_server_notice_wrap) { original_irt(bind) }
  end

end

require 'rack/server'
module Rack
  class Server
    alias_method :original_server, :server
    def server
      # override the SIGINT trap in the Rack::Server.start method allowing multiple choices
      # since #server is also called after the Rack::Server.start trap
      IRT::Utils.load_irt
      IRT.rails_server_sigint_trap = trap('SIGINT') { IRT.rails_signal_handle }
      IRT.rails_server = original_server
    end
  end
end

module IRT

  def rails_signal_handle
    puts
    rails_server_notice_wrap do
      trap('SIGINT'){}
      input = prompter.choose " [s]hutdown, [i]rt or [c]ancel?", /^(s|i|c)$/i,
                              :hint => '[<enter>=s|i|c]', :default => 's'
      trap('SIGINT') { rails_signal_handle  }
      case input
      when 's'
        IRT.rails_server_sigint_trap.call
      when 'i'
        Session.enter :interactive
      end
    end
  end

private

  def rails_server_notice_wrap
    return yield unless rails_server
    IRT.prompter.say_notice "Server suspended"
    yield
    IRT.prompter.say_notice "Server resumed"
  end


  module Session

    alias_method :original_start_file, :start_file
    def start_file(*args)
      original_start_file *args
    ensure
      if IRT.rails_server
        IRB.irb_at_exit
        enter :interactive
      end
    end

  end

  module Commands
    module Rails

      def included(mod)
        mod.module_eval do
          alias_method :abort, :irb_exit
          alias_method :xx, :irb_exit
          alias_method :qq, :irb_exit
        end
      end

      def rails_log_on
        IRT.rails_log = true
        "Rails Log ON"
      end
      alias_method :rlon, :rails_log_on
      alias_method :rlo, :rails_log_on

      def rails_log_off
        IRT.rails_log = false
        "Rails Log OFF"
      end
      alias_method :rloff, :rails_log_off
      alias_method :rlf, :rails_log_off

    end
  end
end

IRB::ExtendCommandBundle.send :include, IRT::Commands::Rails
