class ActiveSupport::BufferedLogger

  alias_method :original_add, :add

  def add(*args)
    original_add(*args)
    message = args[1]
    # no inline log when in rails server and not interactive mode
    return message if IRB.CurrentContext.nil? || IRT.rails_server && IRB.CurrentContext.irt_mode != :interactive
    if IRT.rails_log
      if IRT.dye_rails_log
        plain_message = message.match(/\e\[[\d;]+m/) ? Dye.strip_ansi(message).chomp : message
        irt_message = IRT.dye(plain_message, :log_color) + "\n"
      end
      puts irt_message || message
    end
    message
  end

end


module IRT

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
