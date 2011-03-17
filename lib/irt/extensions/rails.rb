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
    raise IRT::ArgumentTypeError, "You must pass binding instead of #{bind.class.name} object" unless bind.is_a?(Binding)
    IRT.send(:rails_server_notice_wrap) do
      IRT.start
      IRT::Session.enter :binding, bind
    end
  end

end

require 'rack/server'
module Rack
  class Server
    alias_method :original_server, :server
    def server
      # override the SIGINT trap in the Rack::Server.start method allowing multiple choices
      # since #server is also called after the Rack::Server.start trap
      IRT.start
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
      input = IRT::Prompter.choose " [s]hutdown, [i]rt or [c]ancel?", /^(s|i|c)$/i,
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
    IRT::Prompter.say_notice "Server suspended"
    yield
    IRT::Prompter.say_notice "Server resumed"
  end


  module Session

    alias_method :original_run_file, :run_file
    def run_file(*args)
      original_run_file *args
    ensure
      if IRT.rails_server
        IRB.irb_at_exit
        enter :interactive
      end
    end

  end


  module Utils
    alias_method :original_ask_run_new_file, :ask_run_new_file
    # skips asking to run the save file if it is a tmp file in a server session
    # because the server is exiting so no rerun is possible
    def ask_run_new_file(new_file_path, source_path, tmp)
      return if tmp && IRT.rails_server
      original_ask_run_new_file(new_file_path, source_path, tmp)
    end
  end


  module Commands
    module Core

      alias_method :original_rerun, :rerun
      def rerun
        reload!
        original_rerun
      end

    end


    module Rails

      extend self # ignored_echo_commands

      def rails_log_on
        IRT.rails_log = true
        IRT::Prompter.say_notice "Rails Log ON"
      end
      alias_method :rlon, :rails_log_on
      alias_method :rlo, :rails_log_on

      def rails_log_off
        IRT.rails_log = false
        IRT::Prompter.say_notice "Rails Log OFF"
      end
      alias_method :rloff, :rails_log_off
      alias_method :rlf, :rails_log_off

    end
  end
end

IRB::ExtendCommandBundle.send :include, IRT::Commands::Rails
