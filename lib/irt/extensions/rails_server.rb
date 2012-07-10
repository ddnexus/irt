# this file patches the rack server and irt in order to enter irt from the server execution
# you should require this file after loading irt.rb

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

  module Utils
    alias_method :original_ask_run_new_file, :ask_run_new_file
    # skips asking to run the save file if it is a tmp file in a server session
    # because the server is exiting so no rerun is possible
    def ask_run_new_file(new_file_path, source_path, tmp)
      return if tmp && IRT.rails_server
      original_ask_run_new_file(new_file_path, source_path, tmp)
    end
  end

end
