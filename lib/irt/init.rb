require 'pp'

begin
  require 'ap'
rescue LoadError
end

module IRB #:nodoc:
  conf[:PROMPT][:IRT] = { :PROMPT_I => ">> ",
                          :PROMPT_S => '"> ',
                          :PROMPT_C => "?> ",
                      #   :PROMPT_N => "->",
                          :RETURN => "=> %s\n"}
  conf[:PROMPT_MODE] = :IRT
  conf[:ECHO] = false
  conf[:VERBOSE] = false
  conf[:AT_EXIT] = [proc{IRT::Directives.test_summary}]
end

# Easier access to the IRT module
def irt
  IRT
end

# Shows the history
def h(lines=IRT.history.tails_size)
  IRT.history.print_tail lines
end

# History Remove Last
def hrl
  IRT.history.remove_last_line
end

def r!
  puts IRT.colorize(:yellow, "Restarting IRT: `#{ENV['IRT_COMMAND']}`")
  puts "=== Running file #{ENV["IRT_FILE"]} ==="
  exec ENV["IRT_COMMAND"]
end

def add_desc(description)
  IRT.directives.add_desc description
end

def add_test(description=nil)
  IRT.directives.add_test description
end


def desc(description)
  IRT.directives.desc description
end
def test_value_eql?(expected)
  IRT.directives.test_value_eql? expected
end
def test_yaml_eql?(expected)
  IRT.directives.test_yaml_eql? expected
end
def open_session(command=nil)
  IRT.directives.open_session command
end

# Short for quit/exit
def x
  exit
end
alias :q :x

def irt_help
  puts %(
IRT Session Commands
    add_desc(description)      Adds a description for the test in the history
    add_test(descritpion='')   Adds a test in the history, checking the current value (_)
    add_comment(comment)       Adds a comment to the history (same as # comment <enter> command)
                               by automatically choosing the 'test_value_eql?' or 'test_yaml_eql?'
                               method, depending on the type of the current value (_)
    h(n=tail_size)             Prints n lines of the history (n=0 prints all)
    x                          Shortcut for exit
    q                          Shortcut for exit
    r!                         Restart IRT running the same file
    hrl                        History Remove Last line (then sets _ to nil)

IRT Special Session Hints
    -- command                 will not add command to the history
    ++ command                 will add command to the history even if is usually ignored

IRT File Methods
    (You usually paste theese methods copied in blocks from the history)

    desc(description)          Adds a description used in the test
    test_value_eql?(val)       Runs a test checking _ == val and shows a report
    test_yaml_eql?(yaml_dump)  Runs a test checking y _ == yaml_dump
    open_session(command='')   Opens an interactive session at that line
                               eventually executing command on opening
)
end
