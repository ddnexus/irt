# irt

Interactive Ruby Testing - Use irb or rails console for testing.

## Foreword

I like to try my code step by step with irb: it's like playing. But then, when everything
is working as I want, I have to write the tests for future changes, and... that's like working!
It's also somehow silly, because I know that everything is ok because I have just tried it thoroughly,
but I have to re-write the same steps and pack everything into a test-suite.
That's not DRY at all, so I wrote IRT.

After using it for a while I added also quite a lot of other features, not only useful for testing,
but also for easy inspecting and debugging. I hope it will be useful for you too.

### Feedback!!!

This is feedback-driven software. Just send me a line about you and/or what you think about IRT:
that will be a wonderful contribution that will help me to keep improving (and documenting) this software.

My email address is ddnexus at gmail.com ... waiting for your. Ciao.

## What is IRT?

IRT is a very customized irb / rails console that adds a lot of useful features to the standard irb.

IRT records all the steps of your interactive session with irb (or rails console), and can re-run
them as tests, and when something goes wrong, IRT opens an interactive irb (irt) session at the failure
line, giving you immediate feedback and in place editing for easy fixing.

Don't you feel frustrated when a standard test fails, printing a bunch of stuff difficult to distinguish,
and showing NOTHING about the test code that produced the failure?

When something fails IRT assumes that you don't want just to know that something went wrong,
but that:

- you want to know exactly what are the resulting diffs
- you want to look at the code that failed without searching it
- you want to play with it IMMEDIATELY in an interactive session, right in the context of the failure
- you want to eventually edit and possibly fix it, right in the console
- you want to rerun what went wrong right away, without expecting that the entire suite finishes

IRT does all that for you automatically, besides, it adds a few commands that you can use to better interact with your
code and with your testing, plus a few visual aids to your sessions, to make your life a lot easier.

You can have a quick enlightening look by reading the [IRT Tutorial](https://github.com/ddnexus/irt/raw/master/irt-tutorial.pdf "IRT Tutorial")
first, then if you want more details you can read this documentation.

## Installation

    $ [sudo] gem install irt

### Executable Usage

    $ irt --help

### Command/Directives Usage

    >> irt_help

## Colored and Styled Output

This is a nice feature, enabled by default in the terminals that support it, that is really
helpful to visually catch what you need in the mess of the terminal input/output.

IRT uses colors consistently, so you will have an instant feedback about what a text or a label is referring to.

- cyan        for files, saved values (and object 'a' in a diff)
- magenta     for interactive sessions
- black/white for generic stdin/stdout and inspecting sessions (e.g. 'irt my_obj')
- blue        for the Virtual Log and generic labels
- yellow      for result echo (not setting last value), for binding sessions and for tests with diffs
- green       for result echo (setting last value) (and object 'b' in a diff)
- red         for erros, exceptions and rerun

Besides IRT is using reversed and bold styles to compose a more readable/graphical output.

### ANSI colors for Windoze

The Windoze shell does not support ANSI escape codes natively, so if dumping Windoze is a luxury that you
cannot afford, you could use another shell (e.g. the bash that comes with git for windows works), or you can
enable it unless you are running Windows 7 (which has still no known ANSI support at the moment of this writing).

If you want to enable it there is an [official Microsoft page](http://support.microsoft.com/kb/101875 "How to Enable ANSI.SYS in a Command Window")
about that matter, or you can eventually find useful this
[simple tutorial](http://www.windowsnetworking.com/kbase/WindowsTips/Windows2000/UserTips/Miscellaneous/CommandInterpreterAnsiSupport.html "Command Interpreter Ansi Support").

## Sessions / Modes

There are 4 irt modes / session types: file, interactive, inspect, binding.

### File Mode (cyan)

IRT always start in file mode, which simply means that it will execute the code in a file.
Indeed you launch irt passing a path argument of an existing file or dir. If the path does not refer
to any existing file, irt will ask you to confirm that you want to create that file. Eventually
if you don't pass any path argument, irt will create a temporary file.

A new or temporary created file contains just one statement: 'irt' which will open an interactive session.

Notice: When you pass a dir as the path, irt will recursively execute all the '.irt' files in it, so suffixing
with '.irt' the files is not just a convention.

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

You can open an inspecting session with the command 'irt <obj>'.
The 'self' of the new session will be the <obj> itself, so you can inspect it as you would be in its definition class.

When you close the session with 'exit' (or 'x' or 'q'), IRT will not pass back anything from the inspecting session.

### Binding Sessions (yellow)

You can open a binding session from any file being evaluated with the directive 'irt binding'.
The 'self' of the new session will be the 'self' at the line you called it, so you can play with local variables
and methods as you would do it at that line.

If you use 'nano' or 'vi' in a binding session you will open the file that contains the 'bin_irt binding'
call at that line: very handy to edit your code in place.

When you close the session with 'exit' (or 'x' or 'q'), IRT will not pass back anything from the binding session.

## Virtual Log

The Virtual Log is a special filtered-and-extended history of what has been executed at any given time.
It records ALL the lines executed from a file till that moment, and all the RELEVANT steps
you did in an interactive session (inspecting and binding sessions are ignored).

RELEVANT is anything that is changing something in the code you are executing (plus comments and blank lines
used for description and formatting).

### Ignored steps

If you are in an interactive session, make a typo and get an error,
that's not relevant for your code so the typo and the error don't get recorded in the log.

When you just inspect a variable, using p, pp, ap, puts, y, ... or use any irt command...
that are not relevant steps that you want to rerun the next time, so they don't get recorded in the log.

Also , if you are in an inspecting or binding session,
that stesps are not relevant for your tests, so they don't get recorded in the log.

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

That 'pl'-copy or 'cl' plus the 'vi' or 'nano' irt command (or the 'cnn' and 'cvi' commands)
are a very time saver combination. See the tutorial for details.

## Testing

Unlike the traditional testing cycle, where you write your test before or after coding,
IRT writes the tests for you DURING the coding: you will have just to copy and paste them
into an irt file.

Adding a test is as easy as typing 'tt' (or 'add_test') in the console at any given time.
When you type 'tt' irt serializes the current (last) value returned by the last line of code,
and adds one test statement to your log. If you paste the log in the irt file,
you will have it executed the next time you will run the file.

Your tipical testing cycle with IRT is:

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
the variables loaded, so you can imediately and interactively try and fix what went wrong.

If you want to edit the running file, just type 'nano' or  'vi' without any argument and you will open
the file at the current line. Edit, save and exit from the editor, and you will continue your session
from the point you left. You can also 'rerun' the same file (or 'rr') when you need to reload the whole code.

## Editing Tools

### In Place Editing

You can open the current executed file at the current line by just typing 'nano' or 'vi'
and the editor with that name will be opened (in insert mode). Paste and/or edit and save what
you want and 'rerun' (or 'rr') the file to try/test the changes.

You can also open the current executed file in your preferred (GUI) editor with 'edit'.
If you don't like the default editor, you have just to set the IRT.edit_command_format in the ~/.irtrc file
(see "Configuration" below).

You will also find the info about how to automatically have your files syntax highlighted when opened in vi
or nano. See "Goodies" below.

### Copy-Open

You can combine the copy to clipboard feature, with the in place edit feature by using one of the
commands 'cnano', 'cvi' or 'cedit', so saving a lot of boring steps. It use the copy_to_clipboard
command from your system. see below.

### Copy to Clipboard Command

IRT provides a few commands that will use an external command of your system to copy the
last lines to the clipboard: 'copy_lines' (or 'cl'), 'cnano', 'cvi', 'cedit' use that command
aviding you the boring task to select the output from the terminal and copy it.

It uses 'pbcopy' on MacOS (which should be already installed on any mac),
'xclip' on linux/unix (wihch you might need to install) and 'clip' on Windoze
(which is not supported on all WinOS flavours).

You can however set the IRT.copy_to_clipboard_command to any command capable of piping
the stdin to the clipboard.

### Note about CLI text editors

I have never been a big fan of CLI editors like vi or nano, but I really appreciate them
when combined with IRT. Having the file I need to edit, opened at the right line at the touch of a 2 letter
command ('nn' or 'vi') is relly fast and powerful.

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

## Inspecting Tools

### Call irt from your code

You can add 'irt binding' anywhere in your code and have irt opened interactively
to play with your variables and methods during execution (see Binding Sessions)

### Object diff

IRT can compare complex objects and shows the diffs. You can run 'vdiff obj_a, obj_b'
and have a nice and easy to check graphical diff report of the yaml dump of the 2 objects

### Kernel#capture

You can hijack the output of a block to a variable to inspect and test:

    output = capture { some_statement_that_writes_to_stdout }

### Object#own_methods

Get the list of the methods implemented by the object itself (not inherited).

### Inspecting libs

'pp', 'yaml' (and 'ap' if installed) are loaded, so you can use 'pp', 'ap' and 'y' commands to have
a better looking inspection of your objects. Besides they are also enhanced a bit: when invoked
with no arguments, they use the last value (\_) as the default (e.g. just type 'y' instead 'y \_')

## General Tools

### IRT Help

The IRT Commands are the methods that you can call from any IRT console session, while the Directives are
the methods that you can call from any file. Type 'irt_help' in any IRT session to have the complete list.

### Status line

The status line shows the nesting status of your sessions: each time you open a new
session or exit from the current session it is automatically printed.
You can also print it with 'status' (or 'ss') at any time.

### System Shortcuts

Save some typing for common system calls like ls, cat, vi, nano

### FileUtils

All the FileUtils methods are included as commands: just call them in the session
and they will not be logged; if they are part of your testing, use them as usual

    >> rm_rf 'dir/to/remove'           # not logged because it's an irt command
    >> FileUtils.rm_rf 'dir/to/remove' # logged because it's a regular statement

### File insert/eval

You can split your tests and reuse them in other files as you whould do with 'partials' template files.
Use "insert_file 'file/path'" to insert a file into another. It will be evaluated by IRT as
it were written right in the including file itself. Take that into account with variables and last_values.
Besides, you should NOT suffix them with '.irt', so they will not ignored by the irt executable scanning the dirs.

### Code completion and irb-history

Code completion and irb-history are enabled by default (just use the tab and up and down arrows even between sessions)

### Syntax Highlight

In the [goodies dir](https://github.com/ddnexus/irt/tree/master/goodies?raw=true) you can find
a few info about how to use syntax highlight for .irt files in nano and vi, along with a complete 'irt.nanorc' file.

## Configuration

### Upgrade

In order to preserve your eventual customization to the ~/.irtrc file, upgrading from one version
to another requires that you manually delete (or rename) the auto-generated ~/.irtrc file, so irt will
create a new one. Then you can edit it adding your own customization again. If you want to check whether
something is changed or not, here is the [latest irtrc template](https://github.com/ddnexus/irt/raw/master/irtrc).

### Options

If you want to add your custom '~/.irbrc' file, try to load it at the top: if it doesn't
play well with IRT, then copy and paste just part of it.

You can also change a few configuration options in the ~/.irtrc file. The following are the defaults
which should work quite well without any change:

    # will open an interactie session if a test has diffs
    # IRT.irt_on_diffs = true

    # will print the log tail when an interactive session is opened
    # IRT.tail_on_irt = false

    # the lines you want to be printed as the tail
    # IRT.log.tail_size = 10

    # loads irt_helper.rb files automatically
    # IRT.autoload_helper_files = true

    # force true/false regardless the terminal ANSI support
    # IRT.force_color = true

    # the command to pipe to the copied lines that should set the clipboard
    # default to 'pbcopy' on mac, 'xclip -selection c' on linux/unix and 'clip' on windoze
    # IRT.copy_to_clipboard_command = 'your command'

    # the format to build the command to launch nano
    # IRT.nano_command_format = 'nano +%2$d %1$s'

    # the format to build the command to launch vi
    # IRT.vi_command_format ="vi -c 'startinsert' %1$s +%2$d"

    # add your command format if you want to use another editor than nano or vi
    # default 'open -t %1$s' on MacOX; 'kde-open %1$s' or 'gnome-open %1$s' un unix/linux; '%1$s' on windoze
    # IRT.edit_command_format ="your_preferred_GUI_editor %1$s +%2$d"

    # any log-ignored-echo command you want to add
    # IRT.log.ignored_echo_commands << %w[commandA commandB ...]

    # any log-ignored command you want to add (includes all the log-ignored-echo commands)
    # IRT.log.ignored_commands << %w[commandC commandD ...]

    # any command that will not set the last value (includes all the log-ignored commands)
    # IRT.log.non_setting_commands << %w[commandE commandF ...]

### Colors

The default color styles of IRT should be OK in most situation, anyway, if you raeally don't like the colors,
you can switch off the color completely (IRT.force_color = false) or you can also
redefine the colors by redefining them in your .irtrc file.

The following are the default Colorer styles, change them at will:

    Colorer.def_custom_styles({ :bold              => :bold,
                                :reversed          => :reversed,
                                :null              => :clear,

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
                                :diff_b_color      => :green } , true)

### Note about IRT.autoload_helper_files

When autoload_helper_files is true (default) IRT will require all the 'irt_helper.rb' named files in
the descending path fom the current working dir (which is considered the test-root dir) to the dir containing
the irt file being executed. That is useful to add special methods or overriding to your test files without
worring about requiring them from your test files.

For example:

    working_dir
      irt_helper.rb #1
      first_level
        <irt_helper.rb #2
        testA.irt
        testB.irt
        second_level
          irt_helper.rb #3
          test1.irt
          test2.irt

If you are running test1.irt and test2.irt from the working_dir IRT will automatically require the
irt_helper.rb #1, #2 and #3. If you are running the testA.irt and testB.irt, IRT will automatically
require the irt_helper.rb #1, #2. But if you run the same from the first_level dir, the irt_helper.rb #1
will not be loaded, so be careful to be in the right dir to make it work properly.

### Rails 3

You must add the gem to your Gemfile, to make the bundler happy:

    gem 'irt', :group => :console

## Copyright

Copyright (c) 2010-2011 Domizio Demichelis. See LICENSE for details.
