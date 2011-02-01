require 'rubygems'
begin
  require 'ap'
rescue LoadError
end

require 'pp'
require 'yaml'
require 'rbconfig'
require 'pathname'
require 'irt/extensions/kernel'
require 'irt/extensions/object'
require 'irt/extensions/method'
require 'irt/extensions/irb'
require 'irb/completion'
require 'dye'
require 'irt/log'
require 'irt/hunks'
require 'irt/differ'
require 'irt/directives'
require 'irt/session'

module IRT

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  OS = case RbConfig::CONFIG['host_os']
       when /mswin|msys|mingw32|windows/i
         :windows
       when /darwin|mac os/i
         :macosx
       when /linux/i
         :linux
       when /(solaris|bsd)/i
         :unix
       else
         :unknown
       end

  class IndexError < RuntimeError ; end
  class SessionModeError < RuntimeError ; end
  class ArgumentTypeError < RuntimeError ; end
  class NotImplementedError < RuntimeError ; end

  extend self

  attr_accessor :irt_on_diffs, :tail_on_irt, :fix_readline_prompt, :debug,
                :full_exit, :exception_raised, :session_no, :autoload_helper_files, :dye_styles,
                :copy_to_clipboard_command, :nano_command_format, :vi_command_format, :edit_command_format, :ri_command_format
  attr_reader :log, :irt_file, :differ

  def force_color=(bool)
    Dye.color = bool
  end

  def init
    @session_no = 0
    @differ = IRT::Differ
    @irt_on_diffs = true
    @tail_on_irt = false
    @fix_readline_prompt = false
    @autoload_helper_files = true
    @dye_styles = { :null              => :clear,

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
    define_dye_method @dye_styles
    case OS
    when :windows
      @copy_to_clipboard_command = 'clip'
      @edit_command_format = '%1$s'
    when :macosx
      @copy_to_clipboard_command = 'pbcopy'
      @edit_command_format = 'open -t %1$s'
    when :linux, :unix
      @copy_to_clipboard_command = 'xclip -selection c'
      @edit_command_format = case ENV['DESKTOP_SESSION']
                             when /kde/i
                               'kde-open %1$s'
                             when /gnome/i
                               'gnome-open %1$s'
                             end
    end
    @vi_command_format = "vi -c 'startinsert' %1$s +%2$d"
    @nano_command_format = 'nano +%2$d %1$s'
    @ri_command_format =  "qri -f #{Dye.color? ? 'ansi' : 'plain'} %s"
    @debug = false
  end

  def init_files
    @irt_file = IRB.conf[:SCRIPT]
    @log = Log.new
    @log.print_running_file
    IRT::Directives.load_helper_files
  end

  def lib_path
    File.expand_path '../../lib', __FILE__
  end

  # this fixes a little imperfection of the YAML::dump method
  # which adds a space at the end of the class
  def yaml_dump(val)
    yml = "\n" + YAML.dump(val)
    yml.gsub(/ +\n/, "\n")
  end

  def prompter
    @prompter ||= begin
                    require 'prompter'
                    Prompter.new do |pr|
                      def pr.say_echo(result, opts={})
                        opts = {:style => IRT.dye_styles[:ignored_color]}.merge opts
                        say '   #> ' + result.inspect, opts
                      end
                    end
                  end
  end

end
