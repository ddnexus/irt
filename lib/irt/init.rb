module IRB #:nodoc:
  conf[:PROMPT][:IRT] = { :PROMPT_I => "%02n >> ",
                          :PROMPT_S => '   "> ',
                          :PROMPT_C => "%02n ?> ",
                          :PROMPT_N => "%02n -> ",
                          :RETURN   => "   => %s\n" }
  conf[:PROMPT_MODE] = :IRT
  conf[:ECHO] = false
  conf[:VERBOSE] = false
  conf[:AT_EXIT] << proc{IRT::Directives.test_summary}
  conf[:AP_NAME] = 'irt'
  conf[:SAVE_HISTORY] = 100
  conf[:HISTORY_FILE] = File.expand_path '~/.irt-history'
  conf[:AT_EXIT] << proc{ print "\e[0m" if Colorer.color? } # reset colors
end

def method_missing(method, *args, &block)
  (IRB.conf[:MAIN_CONTEXT] && IRB.conf[:MAIN_CONTEXT].irt_mode == :file || method == :irt) && IRT::Directives.respond_to?(method) ?
    IRT::Directives.send(method, *args, &block) :
    super
end

IRT.init_files
