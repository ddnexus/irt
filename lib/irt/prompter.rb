require 'prompter'
module IRT
  class Prompter < ::Prompter

    if IRT.respond_to?(:dye_styles)
      ::Prompter.dye_styles[:say_notice_style] = IRT.dye_styles[:ignored_color]
      ::Prompter.dye_styles[:ask_style]        = IRT.dye_styles[:interactive_color]
    end

    def say_echo(result, opts={})
      if defined?(IRB)
        IRB.CurrentContext.send :output_ignored_echo_value, result
      else
        say_notice result
      end
    end

    def say_notice(message="", opts={})
      opts = { :prefix => '   #> ' }.merge opts
      super message, opts
    end

    def ask(prompt, opts={})
      opts = { :prefix => '   ?> ' }.merge opts
      super prompt, opts
    end

  end
end
