module IRT
  module Commands
    module Help

      def irt_help
        puts %(
#{" NOTICE ".log_color.reversed.bold}
- The #{"Commands".interactive_color.bold} are methods generally available in any IRT session
- The #{"Directives".file_color.bold} are methods available in any file but not in IRT sessions
- The #{"Extensions".log_color.bold} are methods available anywhere

#{" Inspecting Commands ".interactive_color.reversed.bold}
    irt object              Opens an inspecting session into object
    vdiff|vd obj_a, obj_b   Prints the visual diff of the yaml dump of 2 objects
    cat args                Similar to system cat
    ls args                 Similar to system ls

#{" Log Commands ".interactive_color.reversed.bold}
    log|l [limit]           Prints limit or 'tail_size' lines of the virtual log
    full_log|ll             Prints all the lines in the virtual log
    print_lines|pl          Prints the last lines of the current session
                            without numbers (for easy copying)
    print_all_lines|pll     Like print_line but prints all the sessions lines

#{" Editing Commands ".interactive_color.reversed.bold}
    vi                      Uses vi to open the current evalued file at the
                            last evalued line for in place edit
    vi file[, line_no]      Uses vi to open <file> [at the last evalued line]
                            for in place editing
    nano|nn                 Uses nano to open the current evalued file at the
                            last evalued line for in place editing
    nano|nn file[, line_no] Uses nano to open file [at the last evalued line]
                            for in place edit
    edit|ed                 Uses your default GUY editor to open the current
                            evaluated file
    edit|ed file            Uses your default GUY editor to open file

#{" Copy-Edit Commands ".interactive_color.reversed.bold + " (use copy_to_clipboard_command)".interactive_color.bold}
    copy_lines|cl           Copy the last session lines
    copy_all_lines|cll      Copy the lines of all the sessions
    cnano|cnn               Like nano, but copy the last session lines first
    cvi                     Like vi, but copy the last session lines first
    cedit|ced               Like edit, but copy the last session lines first

#{" Test Commands ".interactive_color.reversed.bold + " (only available in interactive sessions)".interactive_color.bold}
    add_desc|dd desc        Adds a description for the test in the log
    add_test|tt             Adds a test in the log, checking the last value (_)
                            by automatically choosing the :_eql?, or :_yaml_eql?
                            method, depending on the type of the last value (_)
    add_test|tt desc        Like add_test but adds a 'desc' directive first

#{" FileUtils Commands ".interactive_color.reversed.bold}
    All the FileUtils methods are availabe as IRT Commands
    (e.g. pwd, touch, mkdir, mv, cp, rm, rm_rf, compare_files, ...)

#{" Enhanced Commands ".interactive_color.reversed.bold}
    p, pp, ap, y            When invoked with no arguments print the last_value
                            (e.g. just type 'y' instead 'y _')

#{" Misc Commands ".interactive_color.reversed.bold}
    x|q                     Aliases for exit (from the current session)
    xx|qq                   Aliases for abort (abort the irt process)
    status|ss               Prints the session status line
    rerun|rr                Reruns the same file
    irt_help|hh             Shows this screen

#{" Session Directives ".file_color.reversed.bold}
    irt                     Opens an interactive session which retains the
                            current variables and the last value (_)
    irt binding             Opens a binding session at the line of the call

#{" Test Directives ".file_color.reversed.bold + " (auto added by the Test Commands)".file_color.bold}
    desc description        Adds a description to the next test
    _eql? val               Runs a test checking _ == val
    _yaml_eql? yaml_dump    Runs a test checking y _ == yaml_dump

#{" Helper Directives ".file_color.reversed.bold}
    insert_file file        Evaluates file as it were inserted at that line
    eval_file               Alias for eval_file
    irt_at_exit block       Ensures execution of block at exit (useful for
                            cleanup of test env)

#{" Extensions ".log_color.reversed.bold}
    Kernel#capture block    Executes block and returns a string containing the
                            captured stdout
    Object#own_methods      Returns the methods implemented by the receiver
                            itself (not inherited)
)
      end
      alias_method :hh, :irt_help

    end
  end
end
