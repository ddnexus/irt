# IRT

Interactive Ruby Tools - Improved irb and rails console with a lot of easy and powerful tools.

## What is IRT?

IRT is an improved irb / rails console (for rails 2 and 3) that adds a lot of features to the standard irb.
If you use IRT in place of irb, you will have all the regular irb/rails console features, plus a lot of tools
that will make your life a lot easier.

### Powerful and easy

- clean colored output for easy reading
- 3 types of sessions: interactive, inspecting and binding
- irb/irt opening from your code (or erb templates) as a binding session
- irb/irt opening from inside the Rails Server window
- optional colored Rails log in the console
- contextual ri doc with completion
- recording of session steps with filtering
- easy testing based on recorded steps
- easy in place opening of backtraced files
- in place editing of objects and files with syntax highlight
- visual comparing tool, navigation and inspecting aids
- system and session shortcuts... and much more

### Testing made easy

IRT records all the steps of your interactive session with irb (or rails console), and can re-run
them as tests. In practice, if you use IRT properly, when you are done with your code, you are done with
your tests.

### Fixing made easy

Don't you feel frustrated when a traditional test fails, printing a bunch of stuff difficult
to distinguish, and showing NOTHING about the test code that produced the failure?

When something fails IRT assumes that you don't want just to know that something went wrong,
but that you actually want to fix it! IRT assumes that...

- you want to know exactly what are the resulting diffs
- you want to look at the code that failed without having to search for it
- you want to play with it IMMEDIATELY in an interactive session, right in the context of the failure
- you want to eventually edit and possibly fix it, right in the console
- you want to rerun the fix right away, without waiting for the end of the whole suite

### Feedback!!!

This is feedback-driven software. Just send me a line about you and/or what you think about IRT:
that will be a wonderful contribution that will help me to keep improving (and documenting) this software.

My email address is ddnexus at gmail.com ... waiting for your. Ciao.

## Try the Tutorial first!

You can have a quick enlightening look (with a lot of screenshots) by reading the [IRT Tutorial](https://github.com/ddnexus/irt/raw/master/irt-tutorial.pdf "IRT Tutorial")
first, then if you want more details you can read this documentation.

## Installation

    $ [sudo] gem install irt

### Executable Usage

    $ irt --help

### Command/Directives Usage

    >> irt_help         # in an irt session

## Colored and Styled Output

This is a nice feature, enabled by default in the terminals that support it, that is really
helpful to visually catch what you need in the mess of the terminal input/output.

IRT uses colors consistently, so you will have an instant feedback about what a text or a label is referring to.

- __cyan__        for files, saved values (and object 'a' in a diff)
- __magenta__     for interactive sessions
- __black/white__ for generic stdin/stdout and inspecting sessions (e.g. 'irt my_obj')
- __blue__        for the Virtual Log, Rails Log and generic labels
- __yellow__      for result echo (not setting last value), for binding sessions and for tests with diffs
- __green__       for result echo (setting last value) (and object 'b' in a diff)
- __red__         for errors, exceptions and rerun

Besides IRT is using reversed and bold styles to compose a more readable/graphical output.

### ANSI colors for Windoze

The Windoze shell does not support ANSI escape codes natively, so if dumping Windoze is a luxury that you
cannot afford, you could use another shell (e.g. the bash that comes with git for windows works), or you can
enable it unless you are running Windows 7 (which has still no known ANSI support at the moment of this writing).

If you want to enable it there is an [official Microsoft page](http://support.microsoft.com/kb/101875 "How to Enable ANSI.SYS in a Command Window")
about that matter, or you can eventually find useful this
[simple tutorial](http://www.windowsnetworking.com/kbase/WindowsTips/Windows2000/UserTips/Miscellaneous/CommandInterpreterAnsiSupport.html "Command Interpreter Ansi Support").

### ANSI colors on jruby

You should use the `IRT.force_color(true)` and `IRT.force_tty(true)` options in the `~/.irtrc` file in order to see colors when you use jruby.

## Sessions / Modes

There are 4 irt modes / session types: file, interactive, inspect, binding.

### File Mode (cyan)

IRT always start in file mode, which simply means that it will execute the code in a file.
Indeed you launch irt passing a path argument of one or more existing files or dirs. If any path does not refer
to any existing file, irt will ask you to confirm that you want to create that file. Eventually
if you don't pass any path argument, irt will create a temporary one-empty-line file.

Notice: When you pass a dir as the path, irt will recursively execute all the '.irt' files in it, so suffixing
with '.irt' the files is not just a convention. It allows to skip any non .irt file, like libraries or files
used with the 'insert\_file' directive.

#### Note about new files

The new created files are implicitly run with the -i (--interative-eol) flag by default.
That flag instruct irt to open an interactive session at the end of the file, so you will have the possibilty
to add your statements. As long as you rerun the file (with the 'rr' command) IRT will remember the flag,
anyway, if the session ends and you have to re-launch it from the command line, you must pass the -i flag
explicitly or no interactive session will be opened automatically.

You can save any running file as another file with the 'save\_as' command.

### Interactive Sessions (magenta)

IRT opens an interactive session when you manually add the 'irt' directive in an irt file,
or automatically, when an exception is raised or when a test has some diffs (fails).

The interactive session retains all the variables and the last returned value at the last evalued line,
so you have the possibility to play with your variables and methods, inspect, try and fix what you want,
and specially use the irt commands to manage your environment.

When you close an interactive session with 'exit' (or 'x' or 'q'), IRT will continue to run the file from the point
it left, retaining also the variables you eventually changed or added, passing back also the last value.
(In practice it's like everything happened in the session has happened in the file).

### Inspecting Sessions (black/white)

You can open an inspecting session with the command 'irt &lt;obj&gt;'.
The 'self' of the new session will be the &lt;obj&gt; itself, so you can inspect it as you would be in its definition class.

When you close the session with 'exit' (or 'x' or 'q'), IRT will not pass back anything from the inspecting session.

### Binding Sessions (yellow)

You can open a binding session from any file with the directive 'irt binding': you don't even need to use the IRT executable.
It works also from the rails code, while the server is running. (See Rails)


The 'self' of the new session will be the 'self' at the line you called it, so you can play with local variables
and methods as you would do it at that line.

If you use 'nano', 'emacs' or 'vi' in a binding session you will open the file that contains the 'irt binding'
call at that line: very handy to edit your code in place.

When you close the session with 'exit' (or 'x' or 'q'), IRT will not pass back anything from the binding session.

## Virtual Log

The Virtual Log is a special filtered-and-extended history of what has been executed at any given time.
It records ALL the lines executed from a file till that moment, and all the RELEVANT steps
you did in an interactive session (inspecting and binding sessions are ignored).

RELEVANT is anything that is changing something in the code you are executing (plus comments and blank lines
used for description and formatting).

### Filtered steps

If you are in an interactive session, make a typo and get an error,
that's not relevant for your code so the typo and the error doesn't get recorded in the log.

When you just inspect a variable, using p, pp, ap, puts, y, ... or use any irt command...
that are not relevant steps that you want to rerun the next time, so they don't get recorded in the log.

Also, if you are in an inspecting or binding session,
that steps are not relevant for your tests, so they don't get recorded in the log.

### Log Management

You can type 'log' (or simply 'l') to have the tail of your log, or type 'full_log' (or simply 'll')
to see all the logged lines from the start.

The lines in the log are graphically grouped in differently colored hunks: cyan for file lines,
magenta for interactive session lines.

The log contains the reference line numbers of the steps: notice that for interactive sessions
they might not be continuous if some step has been filtered out. The numbers could also be repeated
if some step has generated more lines, like it might happen with 'add_test' (or 'tt').

You can copy and save your last steps in a file to rerun later. You can use 'print_lines'
(or 'pl') to print the last session lines without any added reference number, for easy copying,
or if your system supports it you can use 'copy_lines' (or 'cl') and have them right in the clipboard, ready to paste.
You can also do the same with all the session lines using 'print_all_lines' (or 'pll')
or copy them all 'copy_all_lines' (or 'cll').

That 'pl'-copy or 'cl' plus the 'vi', 'nano' or 'emacs' irt command (or the 'cnn' and 'cvi' commands)
are a very time saver combination. See the [IRT Tutorial](https://github.com/ddnexus/irt/raw/master/irt-tutorial.pdf "IRT Tutorial") for details.

## Testing

Unlike the traditional testing cycle, where you write your test before or after coding,
IRT writes the tests for you DURING the coding: you will have just to copy and paste them
into an irt file.

Adding a test is as easy as typing 'tt' (or 'add_test') in the console at any given time.
When you type 'tt' irt serializes the current (last) value returned by the last line of code,
and adds one test statement to your log. If you paste the log in the irt file,
you will have it executed the next time you will run the file.

Your typical testing cycle with IRT is:

- write/change some code in your IDE
- run it with irt and check some value from your code
- add a test ('tt') whenever you want it
- copy the last log lines into the file and save
- rerun the modified test file ('rr')

When a test fails IRT shows you a very readable yaml dump with the differences between
the expected and actual values, so you can immediately find any little problem even inside
a very complex object.

Besides, when a test fails IRT can show you the tail of the running file, (use 'l' or configure
IRT.tail_on_irt = true for automatic tail) so you have an instant feedback about where the
failure comes from. It also opens an interactive session at that point with all
the variables loaded, so you can immediately and interactively try and fix what went wrong.

If you want to edit the running file, just type 'nano, 'emacs' or 'vi' without any argument and you will open
the file at the current line. Edit, save and exit from the editor, and you will continue your session
from the point you left. You can also 'rerun' the same file (or 'rr') when you need to reload the whole code.

### Rerun vs restart

When you make any change in an irt file being evaluated you should perform a 'rerun' (or 'rr')
in order to see the effect of your change.
The 'rerun' command will exit from all the opened sessions, call the at_exit procs and rerun the same file
without reloading any library or required file. That is the fastest behaviour when your changes are limited to any irt file.

If you change some library in any required file and you wants to rerun the same file against the changes,
you need to 'restart' (or 'rs') the whole process, so all the required files will be re-evaluated
and your irt file will be rerun in the new context. That is notably slower in complex application, but guarantees
a fresh loaded environment.

## Editing Tools

### In Place Editing of Files

You can open the current executed file at the current line by just typing 'nano, 'emacs' or 'vi'
and the editor with that name will be opened (in insert mode). Paste and/or edit and save what
you want and 'rerun' (or 'rr') the file to try/test the changes.

You can also open the current executed file in your preferred (GUI) editor with 'edit'.
If you don't like the default editor, you have just to set the IRT.edit_command_format in the ~/.irtrc file
(see "Configuration" below).

You will also find the info about how to automatically have your files syntax highlighted when opened in vi
or nano. See "Goodies" below.

### In Place Editing of Object

With just calling your preferred CLI editor on any object, you can edit the yaml-dumped object and have it
returned in your console:

    >> {:a => 2}.vi  # opens the yaml-dump with vi
    #=> {:an_edited => 'value'}

### Copy-Open

You can combine the copy to clipboard feature, with the in place edit feature by using one of the
commands 'cnano', 'cemacs' 'cvi' or 'cedit', so saving a lot of boring steps. It use the copy_to_clipboard
command from your system. see below.

### Copy to Clipboard Command

IRT provides a few commands that will use an external command of your system to copy the
last lines to the clipboard: 'copy_lines' (or 'cl'), 'cnano', 'cemacs', 'cvi', 'cedit' use that command
avoiding you the boring task to select the output from the terminal and copy it.

It uses 'pbcopy' on MacOS (which should be already installed on any mac),
'xclip' on linux/unix (which you might need to install) and 'clip' on Windoze
(which is not supported on all WinOS flavours).

You can however set the IRT.copy_to_clipboard_command to any command capable of piping
the stdin to the clipboard.

### Note about CLI text editors

I have never been a big fan of CLI editors like vi or nano, but I really appreciate them
when combined with IRT. Having the file I need to edit, opened at the right line at the touch of a 2 letter
command ('nn', 'vi' or 'em') is really fast and powerful.

You have just to know a few very basic commands
like paste, save, quit, and eventually a couple of other, and you will save a lot of time and steps.

For those (like me) that are not used to CLI editors here's a quick reference for for paste save and quit,
(and some edit) that you have to use after a copy-open command from IRT (like 'cnn' or 'cvi'):


    NANO
    paste from clipboard with your usual OS command
    quit            Ctrl-X
                    type 'y'<enter> confirming that you want also to save
                    type 'n' confirming that you don't want to save
    Editing
    copy (line)     Alt/Esc-6
    cut (line)      Ctrl-K
    uncut (paste)   Ctrl-U

    VI-VIM
    paste from clipboard with your usual OS command
    quit            Esc (return to command mode)
                    type ':wq'<enter> if you want to save and quit
                    type ':q!'<enter> if you want quit without save

    Vi has different modes. You have to know at least how to switch mode:
    to insert       type 'i' when in command mode
    to command      type Esc when in insert mode

    Editing
    cut (line)      [Esc (return to command mode)]
                    type 'dd' (or 'cc' that will return to insert mode)
    paste (line)    [Esc (return to command mode)]
                    type 'p'

    EMACS
    paste from clipboard with your usual OS command
    quit            Ctrl-X Ctrl-C
                    type 'y'<enter> confirming that you want also to save
                    type 'n' confirming that you don't want to save
    Editing
    copy (line)     Ctrl-A Ctrl-SPACE Ctrl-N Alt-w
    cut (line)      Ctrl-K
    uncut (paste)   Ctrl-Y


### Note about IDEs

If you prefer to inspect/edit your files with your preferred IDE, you should add a line to
the ~/.irtrc file (create it if you don't have one) indicating the command format for your IDE,
in order to open a file at a certain line.

These are examples of a few setups for different IDEs:

    # RubyMine
    IRT.edit_command_format = %(mine --line %2$s %1$s)

    # Plain Eclipse on Mac X (opens the file but misses the line number)
    IRT.edit_command_format = %(open -a "/Applications/eclipse/Eclipse.app" %1$s)

    # Eclipse with installed EclipseCall plugin (platform independent, file and line number ok)
    # Eclipse should be running
    # http://www.jaylib.org/pmwiki/pmwiki.php/EclipsePlugins/EclipseCall
    # update site: http://www.jaylib.org/eclipsecall
    IRT.edit_command_format = %(java -jar eclipsecall.jar %1$s -G%2$s)

    # NetBeans
    IRT.edit_command_format = %(netbeans --open %1$s:%2$s)

You will use the 'edit' (or 'ed') command to inspect/edit your file with the IDE you setup.
If you create a format for any IDE not listed in the example, please, send it to me, so I will
add it to the list for other users. Thank you.

## Inspecting Tools

### Call irt from your code

You can add 'irt binding' anywhere in your code and have irt opened interactively
to play with your variables and methods during execution (see Binding Sessions)

### Object diff

IRT can compare complex objects and shows the diffs. You can run 'vdiff obj_a, obj_b' (or 'vd obj_a, obj_b')
and have a nice and easy to check graphical diff report of the yaml dump of the 2 objects

### Kernel#capture

You can hijack the output of a block to a variable to inspect and test:

    output = capture { some_statement_that_writes_to_stdout }

### Object#own_methods

Get the list of the methods implemented by the object itself (not inherited).

### Method#location

When possible, it returns an array with file and line where the method is located (defined).
It is suitable to be passed to any in place editing command to open the file at the line.

    >> context.method(:prompt_i).location
    => ["./lib/irt/extensions/irb.rb", 111]
    >> nn _  # will open the file at line 111 with nano

### Method#info

Returns an hash with the info of the method. It is suitable to be passed to any
in place editing command to open the file at the line.

    >> context.method(:prompt_i).info
    => {:file=>"./lib/irt/extensions/irb.rb", :name=>"prompt_i", :line=>111, :arity=>-1, :class_name=>"IRB::Context"}
    >> nn _  # will open the file at line 111 with nano

### Inspecting libs

'pp' and 'yaml' are loaded, so you can use 'pp' and 'y' commands to have
a better looking inspection of your objects. Besides 'p', 'pp', 'y' and 'ap' (if you require it in the .irtrc file)
are also enhanced a bit: when invoked with no arguments, they use the last value (\_) as the default (e.g. just type 'y' instead 'y \_')

### In place inspecting/editing of backtraced files

When an error occurs, IRT shows you an indexed exception backtrace: each file:line in the backtrace
has an index number (in brackets) that you can use to open that file at that line with your preferred in-place editor.

You have just to type '&lt;editor&gt; &lt;index&gt;' (&lt;editor&gt; is one of 'vi', 'nano' (or 'nn'), 'emacs' (or 'em'), 'edit' (or 'ed'),
and &lt;index&gt; is the index number shown in the backtrace), and you will open it in insert mode. Example:

    # backtraced line: from /Users/dd/dev/hobo3/hobo/lib/hobo/controller/model.rb:57:in `each' [3]
    >> nn 3

Besides, if you copy a traceline from another source (which obviously does not have backtrace indexes)
like a user group or a rails application trace, just paste it as the argument of any editor command
(even if it is splitted over many lines like in the first example below) and IRT will open the file at
the wanted line. Example:

    >> nn "from /opt/local/lib/ruby/site_r
    "> uby/1.8/rubygems/custom_require.rb:31:in `gem_original_require'"
    # or a rails trace line
    >> nn "activesupport (3.0.3) lib/active_support/dependencies.rb:491:in `load_missing_constant'"

## General Tools

### Permanent last value (_)

IRT tries to keep the relevant results from running code, separated from the results of the inspecting
and documentation commands. In practice all the IRT commands, and the inspecting commands (like 'p', 'pp', 'y' and 'ap')
don't set the last value, so you can mix them with your code and the '_' will remain set to your last relevant result.
That is specially useful when you want to add a test with the 'add_test' (or 'tt') command.

### Contextual ri doc with autocompletion

IRT offers the 'ri' command implemented with fastri for RUBY_VERSION < 1.9.2, or 'bri' for RUBY_VERSION >= 1.9.2:
you must install the right gem for your ruby version in order to make it work.
See also the IRT.ri_command_format option if you want to customize it.

In its basic form the 'ri' command can accept a string as the system ri command does (you can even omit the quotes).

    >> ri reverse
    ------------------------------------------------------ Multiple choices:

          1  ActiveSupport::Multibyte::Chars#reverse
          2  Array#reverse
          3  IPAddr#reverse
          4  String#reverse

    >> ri 4
    --------------------------------------------------------- String#reverse
         str.reverse   => new_str
    ------------------------------------------------------------------------
         Returns a new string with the characters from str in reverse order.

            "stressed".reverse   #=> "desserts"

But unlike the system command, when the search results in multiple choices, you can just type the
index of the choice and get the doc you want with less typing. The shortcuts in the list will work
until you use another command but 'ri'

Besides it offers a very useful contextual search, that will find the ri doc of the specific method used by the receiver.
Example:

    # autocompletion
    >> ri "any string".eq[TAB][TAB]
    .eql?    .equal?

    >> ri "a string".eql?
    ------------------------------------------------------------ String#eql?
         str.eql?(other)   => true or false
    ------------------------------------------------------------------------
         Two strings are equal if the have the same length and content.

    >> ri [].eql?
    ------------------------------------------------------------- Array#eql?
         array.eql?(other)  -> true or false
    ------------------------------------------------------------------------
         Returns true if array and other are the same object, or are both
         arrays with the same content.

If you want to search a literal string (i.e. not interpreted) you must use single or double quotes
and the string will be passed verbatim to the system ri command.

If you have a long documentation coming from the ri search, or even if you want just to keep your screen clean,
you can use the 'pri' (i.e. paged ri). It works exactly like 'ri', but uses the pager to show any result from the ri search.

### IRT Help

The IRT Commands are the methods that you can call from any IRT console session, while the Directives are
the methods that you can call from any file. Type 'irt_help' in any IRT session to have the complete list.

### Status line

The status line shows the nesting status of your sessions: each time you open a new
session or exit from the current session it is automatically printed.
You can also print it with 'status' (or 'ss') at any time.

### Quasi-shell

Save some typing for system calls and avoid to open a shell.
You can use the 'sh' as an alias of 'system' with the difference that you don't need to use quotes
(although the quotes work anyway), and the command will not be logged. Examples:

    >> sh ls -F
    >> sh tail /some/path
    >> sh git rebase -i HEAD~5
    >> sh cat #{file_path}

### Pager

When you have any long string to inspect, or some code printing a lot of text to stdout
you can use the 'pager' (or 'pg') command, and the output will be managed by the pager
('less' by default, but you can change it with the pager\_format\_command option).

    # with a string
    pg some_long_string

    # with a block of code printing to stdout
    pg { irt_help }

### FileUtils

All the FileUtils methods are included as commands: just call them in the session
and they will ignored by the log; if they are part of your testing, use them as usual:

    >> rm_rf 'dir/to/remove'           # ignored because it's an irt command
    >> FileUtils.rm_rf 'dir/to/remove' # logged because it's a regular statement

Notice: The FileUtils commands (unlike the other IRT commands) do echo their result,
although they don't set the last value \_ (like any other IRT command). In order to distinguish
that behaviour from a regular setting statement, their result is printed in yellow instead than in green.
and the prompt is '#&gt;' instead '=&gt;'. Example:

    >> a = 5
    => 5
    >> pwd
    #> "/Users/dd/dev/irt" # yellow ignored and non setting _
    >> _
    => 5
    >> FileUtils.pwd
    => "/Users/dd/dev/irt" # green logged and setting _
    >> _
    => "/Users/dd/dev/irt"

### File insert/eval

You can split your tests and reuse them in other files as you would do with 'partials' template files.
Use "insert_file 'file/path'" to insert a file into another. It will be evaluated by IRT as
it were written right in the including file itself. Take that into account with variables and last_values.
Besides, you should NOT suffix them with '.irt', so they will get ignored by the irt executable scanning the dirs.

### Code completion and irb-history

Code completion and irb-history are enabled by default (just use the tab and up and down arrows even between sessions)

### Syntax Highlight

In the [goodies dir](https://github.com/ddnexus/irt/tree/master/goodies?raw=true) you can find
a few info about how to use syntax highlight for .irt files in nano and vi, along with a complete 'irt.nanorc' file.

## Configuration

IRT tries to load a ~/.irtrc file at startup, so you can customize a few options.

If you want to add your custom '~/.irbrc' file, try to load it at the top: if it doesn't
play well with IRT, then copy and paste just part of it.

You can also change the configuration options in the ~/.irtrc file. The following are the defaults
which should work quite well without any change:

    # uncomment if you want to use the awesome_print gem
    # require 'ap'

    # set this to true if your prompt get messed up when you use the history
    # IRT.fix_readline_prompt = false

    # will open an interactie session if a test has diffs
    # IRT.irt_on_diffs = true

    # will print the log tail when an interactive session is opened
    # IRT.tail_on_irt = false

    # the lines you want to be printed as the tail
    # IRT.log.tail_size = 10

    # loads irt_helper.rb files automatically
    # IRT.autoload_helper_files = true

    # forces tty (standard use with jruby)
    # IRT.force_tty(true)

    # forces color regardless the terminal ANSI support (standard use with jruby)
    # IRT.force_color(true)

    # the command to pipe to the copied lines that should set the clipboard
    # default to 'pbcopy' on mac, 'xclip -selection c' on linux/unix and 'clip' on windoze
    # IRT.copy_to_clipboard_command = 'your command'

    # the format to build the command to launch nano
    # IRT.nano_command_format = %(nano +%2$d "%1$s")

    # the format to build the command to launch vi
    # IRT.vi_command_format = %(vi "%1$s" +%2$d)

    # the format to build the command to lauch emacs
    # IRT.emacs_command_format = %(emacs +%2$d "%1$s")

    # the format to build the command to launch the ri tool
    # if RUBY_VERSION < 1.9.2 uses qri (from fastri) else bri
    # IRT.ri_command_format = %(qri -f #{Dye.color? ? 'ansi' : 'plain'} "%s")
    # IRT.ri_command_format = %(bri "%s")

    # add your command format if you want to use another editor than nano or vi
    # default 'open -t %1$s' on MacOX; 'kde-open %1$s' or 'gnome-open %1$s' un unix/linux; '%1$s' on windoze
    # IRT.edit_command_format = "your_preferred_GUI_editor %1$s +%2$d"

    # any log-ignored-echo command you want to add
    # IRT.log.ignored_echo_commands << [:commandA, :commandB ...]

    # any log-ignored command you want to add (includes all the log-ignored-echo commands)
    # IRT.log.ignored_commands << [:commandC, :commandD ...]

    # any command that will not set the last value (includes all the log-ignored commands)
    # IRT.log.non_setting_commands << [:commandE, :commandF ...]

    # shows the rails log in console
    # IRT.rails_log = true

    # colors with :log_color (default blue) the rails log for easy reading
    # IRT.dye_rails_log = true

### Colors

The default color styles of IRT should be OK in most situation, anyway, if you really don't like the colors,
you can switch off the color completely with `IRT.force_color(false)` or you can also
redefine the colors by redefining them in your .irtrc file.

The following are the default Dye (gem) styles, change them at will:

    IRT.dye_styles = { :null              => :clear,

                       :log_color         => :blue,
                       :file_color        => :cyan,
                       :interactive_color => :magenta,
                       :inspect_color     => :clear,
                       :binding_color     => :yellow,
                       :actual_color      => :green,
                       :ignored_color     => :yellow,

                       :error_color       => :red,
                       :ok_color          => :green,
                       :diff_color        => :yellow,
                       :diff_a_color      => :cyan,
                       :diff_b_color      => :green }

### Note about IRT.autoload_helper_files

When autoload_helper_files is true (default) IRT will require all the 'irt_helper.rb' named files in
the descending path fom the current working dir (which is considered the test-root dir) to the dir containing
the irt file being executed. That is useful to add special methods or overriding to your test files without
worring about requiring them from your test files.

For example:

    working_dir/
      irt_helper.rb #1
      first_level/
        irt_helper.rb #2
        testA.irt
        testB.irt
        second_level/
          irt_helper.rb #3
          test1.irt
          test2.irt

If you are running test1.irt and test2.irt from the working_dir IRT will automatically require the
irt_helper.rb #1, #2 and #3. If you are running the testA.irt and testB.irt, IRT will automatically
require the irt_helper.rb #1, #2. But if you run the same from the first_level dir, the irt_helper.rb #1
will not be loaded, so be careful to be in the right dir to make it work properly.

Notice: the irt helpers files are 'require'd (not 'load'ed). For that reason they are
suitable for adding constants, methods, require(s) that will be loaded only once.
If you change any irt helper you should 'restart (or 'rs') once before your changes get reloaded.

## Rails

You can use irt instead of the standard Rails console, by just calling the irt executable from
any Rails application dir. If you want to skip the autoloading of the Rails app even from that
dir, you must pass the -n option (--no-rails).

    $ cd my_rails_app

    # will use the test environment in sandbox mode
    $ irt -b--sandbox -etest

    # will open a normal irt console, skipping the rails app
    $ irt -n

By default IRT will output the rails log (colored in blue) right in the console.
You can switch the rails log ON or OFF by using the 'rails\_log\_on' (or 'rlo') and 'rails\_log\_off' (or 'rlf')
commands in any session, besides you can set the option IRT.rails_log to true or false in the ~/.irtrc file.

## Rerun, restart, reload!-rerun

The 'rerun' (or 'rr') irt command in rails will also perform a 'reload!' first, so if you are in development mode
your changes will be reloaded, so the command should do what you need: if it doesn't you
should use the regular 'restart' (or 'rs') as the last resort. The 'restart' causes the Rails environment
to be fully reloaded, so it is slower, but guaranteed.

### Rails Server Sessions

Notice: this feature is optional. If you want to enable it you must `require 'irt/extensions/rails_server'` after
the irt gem gets loaded.

The server sessions are a quick way to interact with your application while your server is running,
without the need to launch a the irt executable: you can do almost everything you can from a regular IRT session
launched from the irt executable, besides you have access to the server internals.

If you want to open a session from your Rails code or from a template while the server is running,
you don't have to use the IRT executable: you can just add an 'irt binding' statement where you want
(even in a erb template), load the page in the browser and IRT will open a Binding Session right in the server's console.

    # will open an IRT Binding Session in the server window
    irt binding

Besides, if you want to open an Interactive Session, you have just to type Ctrl-C in the server console and
you will be asked if you want to shutdown the server or open an IRT session.

    => Booting Mongrel
    => Rails 3.0.4 application starting in development on http://0.0.0.0:3000
    => Call with -d to detach
    => Ctrl-C to shutdown server
    ^C
       #> Server suspended
       ?>  [s]hutdown, [i]rt or [c]ancel? [<enter>=s|i|c]

Notice that the execution of the web response is halted until you exit from the session.
When you exit, the response process will be resumed, and the server will return to its normal behaviour.

Note: The Server Sessions are known to work with WEBrick and Mongrel (using Rack).
WEBrick might spit some error closing an Interactive Session, while it is ok
with Binding Sessions. Mongrel works perfectly.

### Rails 3

You must add the gem to your Gemfile, to make the bundler happy:

    gem 'irt'

eventually adding it only to the group that you prefer. Anyway, if the irt executable detects that you don't have it set,
it will ask and eventually add it for you.

## Known Issues (and fixes)

### Readline history

The ruby readline library may have a problem with the history when you use an ANSI colored prompt
(see this [readline bug](http://www.ruby-forum.com/topic/213807)).
If your prompt get messed up while you are navigating the history, you need to enable the 'fix\_readline\_prompt'
configuration option (see the Configuration session). That option fixes the prompt when it get messed, but messed
it if it doesn't, so if you switch among different ruby versions, you might need to make it conditional. For example:

    if IRT::RubyVersion <= '1.8.7'
      IRT.fix_readline_prompt = true
    end

#### MacOS X and libedit

If you are on MacOS X, your ruby might use libedit instead of readline. In that case you are not affected
by the above readline bug, but you will be bothered by a few other problems, so you might want to link your ruby
to readline. Depending on your installation, you have a few different choices to avoid to reinstall ruby.

Useful links you can start with:

* [RVM-readline](http://rvm.beginrescueend.com/packages/readline/)
* [MacPort-readline](http://henrik.nyh.se/2008/03/irb-readline)

### Yaml serialization

IRT uses yaml serialization, and inherits its limits (e.g.: Yaml cannot dump anonymous classes, MatchData, object that contains binding, etc.)
so if you stumble upon on one of them, you have just to test the subparts of the object that you cannot dump. For example, instead of testing one whole anonymous
class, (which is however a bad idea) you can add tests for the values returned by its methods or variables.

### Irb jobs

IRT disables the traditionals irb jobs. You can still open any session like you do with the standard irb,
but the new session is not created as a new thread, therefore the 'jobs' related commands are useless.
In practice the only real limitation is that you have to exit from an inspecting or binding session
in order to switch back to an interactive session, while threaded sessions would allow you to switch and kill the thread
indipendently. This will probably be addressed in a next version of irt.
Please, send me a line if this issue is bugging you, so I will try to fix it faster.

## Copyright

Copyright (c) 2010-2012 Domizio Demichelis. See LICENSE for details.
