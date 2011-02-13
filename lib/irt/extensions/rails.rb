class ActiveSupport::BufferedLogger

  alias_method :original_add, :add

  def add(*args)
    message = original_add(*args)
    return message if IRT.rails_server # no inline log when irt in rails server
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

require 'rack/server'
module Rack
  class Server
    alias_method :original_server, :server
    def server
      # override the SIGINT trap in the Rack::Server.start method allowing multiple choices
      # since #server is also alled after the Rack::Server.start trap
      trap('SIGINT') do
        IRT::Utils.load_irt
        IRT.rails_signal_handle
      end
      IRT.rails_server = original_server
    end
  end
end

module IRT

  def rails_signal_handle
    trap('SIGINT'){}
    i = prompter.choose(" [s]hutdown, [i]rt or [c]ancel?", /^(s|i|c)$/i,
                        :hint => '[<enter>=s|i|c]', :default => 's', :echo => false)
    case i
    when 's'
      if rails_server.respond_to?(:shutdown)
        rails_server.shutdown
      else
        exit
      end
    when 'i'
      rails_sigint_wrap{ Session.enter :interactive }
    when 'c'
      trap('SIGINT') { rails_signal_handle }
    end
  end

  def rails_sigint_wrap
    return yield unless rails_server
    trap('SIGINT') { IRB.CurrentContext.irb.signal_handle }
    yield
    trap('SIGINT') { rails_signal_handle  }
  end

  module Commands
    module Rails

      extend self

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
