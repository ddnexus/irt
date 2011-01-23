module IRB #:nodoc:
  conf[:AP_NAME] = 'irt'
  conf[:PROMPT][:IRT] = { :PROMPT_I => "%02n >> ",
                          :PROMPT_S => '   "> ',
                          :PROMPT_C => "%02n ?> ",
                          :PROMPT_N => "%02n -> ",
                          :RETURN   => "   => %s\n" }
  conf[:PROMPT_MODE] = :IRT
  conf[:ECHO] = false
  conf[:VERBOSE] = false
  conf[:SAVE_HISTORY] = 100
  conf[:HISTORY_FILE] = File.expand_path '~/.irt-history'
  conf[:AT_EXIT] ||= []
  conf[:AT_EXIT] << proc{IRT::Directives.test_summary}
  conf[:AT_EXIT] << proc{ print "\e[0m" if Colorer.color? } # reset colors
end

IRT.init_files
