require 'irb'
require 'irt/extensions/irb/context'
require 'irt/extensions/irb/commands'

module IRB #:nodoc:

  class << self
    alias_method :irb_init_config, :init_config
    alias_method :irb_setup, :setup
  end

  def IRB.setup(ap_path=nil)
    irb_setup(ap_path)
    IRT.before_run
  end

  def IRB.init_config(ap_path)
    irb_init_config(ap_path)

    @CONF[:AP_NAME] = 'irt'
    @CONF[:PROMPT][:IRT] = { :PROMPT_I => "%02n >> ",
                             :PROMPT_S => '   "> ',
                             :PROMPT_C => "%02n ?> ",
                             :PROMPT_N => "%02n -> ",
                             :RETURN   => "   => %s\n",
                             :RETURN_I => "   #> %s\n" }
    @CONF[:PROMPT_MODE] = :IRT
    @CONF[:ECHO] = false
    @CONF[:VERBOSE] = false
    @CONF[:SAVE_HISTORY] = 100
    @CONF[:HISTORY_FILE] = File.expand_path '~/.irt-history'
    @CONF[:AT_EXIT] ||= []
    @CONF[:AT_EXIT] << proc{ IRT::Session.enter(:interactive) if IRB.CurrentContext.irt_mode == :file } if !!ENV['IRT_INTERACTIVE_EOF']
    @CONF[:AT_EXIT] << proc{ IRT::Directives.test_summary }
    @CONF[:AT_EXIT] << proc{ print "\e[0m" if Dye.color? } # reset colors
    @CONF[:RC_NAME_GENERATOR] = proc {|rc| File.expand_path '~/.irtrc' }

    IRT.init_config
  end

end
