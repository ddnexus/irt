# allows standard rails 3 console to run without loading irt
unless defined?(Rails::Console) && !ENV['IRT_COMMAND']

at_exit{ Dye.print_reset_colors }

require 'rubygems'

require 'pp'
require 'yaml'
require 'rbconfig'
require 'pathname'
require 'dye'
require 'irt/log'
require 'irt/hunks'
require 'irt/differ'
require 'irt/directives'
require 'irt/session'
require 'irt/ruby_version'
require 'irt/utils'

module IRT

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

  EDITORS = { :vi    => nil,
              :nano  => :nn,
              :emacs => :em,
              :edit  => :ed }

  EDITORS.keys.each {|k| attr_accessor :"#{k}_command_format" }

  class IndexError < RuntimeError ; end
  class SessionModeError < RuntimeError ; end
  class ArgumentTypeError < RuntimeError ; end
  class NotImplementedError < RuntimeError ; end

  extend self

  attr_accessor :irt_on_diffs, :tail_on_irt, :fix_readline_prompt, :debug,
                :rails_log, :dye_rails_log, :rails_server, :rails_server_sigint_trap,
                :full_exit, :session_no, :autoload_helper_files, :dye_styles,
                :copy_to_clipboard_command, :pager_command, :ri_command_format

  attr_reader :log, :irt_file, :initialized

  def force_color=(bool)
    Dye.color = bool
  end

  def init_config
    @irt_on_diffs = true
    @tail_on_irt = false
    @fix_readline_prompt = false
    @rails_log = true
    @dye_rails_log = true
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
    @vi_command_format = %(vi "%1$s" +%2$d)
    @nano_command_format = %(nano +%2$d "%1$s")
    @emacs_command_format = %(emacs +%2$d "%1$s")
    @ri_command_format =  IRT::Commands::Ri::GEM == 'bri' ? %(bri "%s") : %(qri -f #{Dye.color? ? 'ansi' : 'plain'} "%s")
    @pager_command = 'less -R'
    @debug = false
  end

  def setup
    IRB::ExtendCommandBundle.class_eval do
      [:p, :y, :pp, :ap].each do |m|
        next unless begin
                      method(m)
                    rescue NameError
                    end
        define_method(m) do |*args|
          args = [context.last_value] if args.empty?
          super *args
        end
      end
    end
    @initialized = true
    init_file
  end

  def init_file(file = nil)
    @session_no = 0
    irt_file = file.nil? ? IRB.conf[:SCRIPT] : (IRB.conf[:SCRIPT] = file)
    @irt_file = Pathname.new(irt_file).realpath
    @log = Log.new
    IRT::Directives.load_helper_files
    @log.print_running_file
  end

  # this will create a tmp file and start IRB
  # but it will be left in file mode at EOF (sort of irt-standby)
  def start
    return if initialized
    puts copyright
    ARGV.clear
    ARGV.push create_tmp_file
    IRB.start
  end

end

require 'irt/extensions/irb'
require 'irb/completion'
IRT.init_config
require 'irt/extensions/kernel'
require 'irt/extensions/object'
require 'irt/extensions/method'
require 'irt/prompter'
require 'irt/extensions/rails' if defined?(ActiveSupport::BufferedLogger)

end
