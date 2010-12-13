module IRB #:nodoc:
  conf[:PROMPT][:IRT] = { :PROMPT_I => ">> ",
                          :PROMPT_S => '"> ',
                          :PROMPT_C => "?> ",
                      #   :PROMPT_N => "->",
                          :RETURN => "=> %s\n"}
  conf[:PROMPT_MODE] = :IRT
  conf[:ECHO] = false
  conf[:VERBOSE] = false
  conf[:AT_EXIT] << proc{IRT::Directives.test_summary}
end

def method_missing(method, *args, &block)
  IRT::Directives.respond_to?(method) ? IRT::Directives.send(method, *args, &block) : super
end

# Short for quit/exit
def x
  exit
end
alias :q :x

def irt_help
  puts %(
Session Directives
    add_desc|ad description      Adds a description for the test in the history
    add_test|at [descritpion]    Adds a test in the history, checking the current value (_)
                                 by automatically choosing the 'test_value_eql?' or 'test_yaml_eql?'
                                 method, depending on the type of the current value (_)
    add_comment|ac comment       Adds a comment to the history (same as # comment <enter> command)
    add_empty_line|ael           Adds an empty line for formatting convenience
    history|h n=tail_size        Prints n lines of the history (n=0 prints all lines)
    h0|hh                        Same as `h 0`: prints all lines
    history_remove_last|hrl      History Remove Last session line (then sets _ to nil)
    history_clear                Clears the session history (then sets _ to nil)
    x|q                          Shortcuts for exit
    x!|q!                        Full exit (doesn't open other sessions)
    r!|rr                        Restarts IRT and reruns the same file

Special Session Hints
    -- command                   Do not add command to the history
    ++ command                   Add command to the history even if it's usually ignored

File Methods
    (You usually copy theese methods in block from the history and paste into the file)

    desc description             Adds a description to the test
    test_value_eql? val          Runs a test checking _ == val
    test_yaml_eql? yaml_dump     Runs a test checking y _ == yaml_dump
    open_session|irt [command]   Opens an interactive session at that line
                                 eventually executing command on opening

File Helpers
    irt_at_exit block            Ensure execution of block at exit (useful for cleanup test env)
    eval_file file               Evaluate file as it were inserted at that line
)
end
