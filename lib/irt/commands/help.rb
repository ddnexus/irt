module IRT
  module Commands
    module Help

      def irt_help
        ensure_session
        puts %(
#{label " Irt Help ", :log_color}
- The #{IRT.dye "Commands", :interactive_color, :bold} are methods generally available in any IRT session
- The #{IRT.dye "Directives", :file_color, :bold} are methods available in any file but not in IRT sessions
- The #{IRT.dye "Extensions", :log_color, :bold} are methods available anywhere

#{label " Inspecting Commands ", :interactive_color}
    irt object              Opens an inspecting session into object
    vdiff|vd obj_a, obj_b   Prints the visual diff of the yaml dump of 2 objects
    p, pp, ap, y            When invoked with no arguments print the last_value
                            (e.g. just type 'y' instead 'y _')

#{label " Log Commands ", :interactive_color}
    log|l [limit]           Prints limit or 'tail_size' lines of the virtual log
    full_log|ll             Prints all the lines in the virtual log
    print_lines|pl          Prints the last lines of the current session
                            without numbers (for easy copying)
    print_all_lines|pll     Like print_line but prints all the sessions lines

#{label " In Place Editing Commands ", :interactive_color}
    (<editor> can be 'vi', 'nano|nn', 'emacs|em', 'edit|ed')
    <editor>                Uses <editor> to open the current evalued file at
                            the current evalued line for in place edit
    <editor> file[, line]   Uses <editor> to open file [at line] for in place
                            editing
    <editor> hash           Uses <editor> to open hash[:file] at the hash[:line]
    <editor> array          Uses <editor> to open array[0] at the array[1] line
    <editor> traceline      Uses <editor> to open the file at line in traceline
                            e.g.: nn "from /path/to/file.rb:34:in 'any_method'"
                                  nn "a_gem (1.2.3) lib/file.rb:13:in 'a_meth'"
    <editor> n              Uses <editor> to open the backtraced file [n] at
                            the backtraced line

#{label( " Copy-Edit Commands ", :interactive_color ) + IRT.dye(" (use copy_to_clipboard_command)", :interactive_color, :bold)}
    copy_lines|cl           Copies the last session lines to the clipboard
    copy_all_lines|cll      Copies all the sessions' lines to the clipboard
    c<editor>               Like `copy_lines` and <editor> in just one step

#{label(" Test Commands ", :interactive_color) + IRT.dye(" (only available in interactive sessions)", :interactive_color, :bold)}
    add_desc|dd desc        Adds a description for the test in the log
    add_test|tt             Adds a test in the log, checking the last value (_)
                            by automatically choosing the :_eql?, or :_yaml_eql?
                            method, depending on the type of the last value (_)
    add_test|tt desc        Like add_test but adds a 'desc' directive first'
    save_as|sa path         Saves the current irt file as path

#{label " FileUtils Commands ", :interactive_color}
    All the FileUtils methods are availabe as IRT Commands
    (e.g. pwd, touch, mkdir, mv, cp, rm, rm_rf, compare_files, ...)

#{label " Documentation Commands ", :interactive_color}
    ri "string_to_search"   Search the ri doc for the literal string_to_search
    ri to_search            Search the ri doc for to_search (without quote)
                            If to_search represents any object in your code
                            it looks for the obj.class documentation
                            e.g.: ri arr #=> (where arr=[]) ri doc for Array
                                  ri ""  #=> ri doc for String
    ri obj.any_method       Search the method.owner ri doc for of any_method
                            (no quotes needed, and completion available)
                            e.g.: ri "".eql?  #=> ri doc for String#eql?
                                  ri [].eql?  #=> ri doc for Array#eql?
    ri n                    Search the ri doc for the method n in a multiple
                            choices list
    pri ...                 Like the above commands for `ri ...` but uses the
                            pager to show the result

#{label(" Rails Commands ", :interactive_color) + IRT.dye(" (only available for Rails Apps)", :interactive_color, :bold)}
    rails_log_on            Turn the rails log-in-console ON
    rlon|rlo                Aliases for rails_log_on
    rails_log_off           Turn the rails log-in-console OFF
    rloff|rlf               Aliases for rails_log_off

#{label " Misc Commands ", :interactive_color}
    x|q                     Aliases for exit (from the current session)
    xx|qq                   Aliases for abort (abort the irt process)
    status|ss               Prints the session status line
    run file                Run an irt file (exiting from the current sessions)
    rerun|rr                Reruns the current irt file (exiting from the
                            current sessions)
    restart|rs              Restart the executable, reload IRT (and Rails) and
                            rerun the current file
    irt_help|hh             Shows this screen
    sh command              Alias for system("command") (no quotes needed)
    pager|pg string|block   Uses the pager to show a long string or executes
                            block and shows its captured stdout

#{label " Session Directives ", :file_color}
    irt                     Opens an interactive session which retains the
                            current variables and the last value (_)
    irt binding             Opens a binding session at the line of the call

#{label(" Test Directives ", :file_color) + IRT.dye(" (auto added by the Test Commands)", :file_color, :bold)}
    desc description        Adds a description to the next test
    _eql? val               Runs a test checking _ == val
    _yaml_eql? yaml_dump    Runs a test checking y _ == yaml_dump

#{label " Helper Directives ", :file_color}
    insert_file file        Evaluates file as it were inserted at that line
    eval_file               Alias for eval_file
    irt_at_exit block       Ensures execution of block at exit (useful for
                            cleanup of test env)

#{label " Extensions ", :log_color}
    Kernel#capture block    Executes block and returns a string containing the
                            captured stdout
    Object#own_methods      Returns the methods implemented by the receiver
                            itself (not inherited)
    Object#<editor>         (<editor> can be 'vi', 'nano|nn', 'emacs|em')
                            Yaml-dump the object in a tmp.yml file and opens it
                            with <editor>. After your editing and save returns
                            the evaluated yaml file
                            e.g.: {:a => 2}.vi  #=> {:an_edited => 'value'}
    Method#location         When possible, it returns file and line where the
                            method is defined. It is uitable to be passed to the
                            in place editing commands.
    Method#info             Returns useful info about the method. It is suitable
                            to be passed to the in place editing commands.
)
      end
      alias_method :hh, :irt_help

    private
      def label(string, color)
        IRT.dye string, color, :reversed, :bold
      end

    end
  end
end
