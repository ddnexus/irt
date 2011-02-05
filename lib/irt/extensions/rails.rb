class ActiveSupport::BufferedLogger

  alias_method :original_add, :add

  def add(*args)
    message = original_add(*args)
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

module IRT
  module Commands
    module Rails

      extend self

      def rails_log_on
        IRT.rails_log = true
      end

      def rails_log_off
        IRT.rails_log = false
      end

    end
  end
end

IRB::ExtendCommandBundle.send :include, IRT::Commands::Rails
