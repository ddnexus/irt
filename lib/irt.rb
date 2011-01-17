
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
require 'irt/extensions/irb'
require 'irb/completion'
require 'colorer'
require 'irt/log'
require 'irt/hunks'
require 'irt/differ'
require 'irt/directives'

module IRT

  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  class BindingError < RuntimeError ; end
  extend self

  attr_accessor :irt_on_diffs, :tail_on_irt,
                :full_exit, :exception_raised, :session_no, :autoload_helper_files,
                :copy_to_clipboard_command, :nano_command_format, :vi_command_format, :edit_command_format
  attr_reader :log, :file, :differ, :os

  def directives
    IRT::Directives
  end

  def force_color=(bool)
    Colorer.color = bool
  end

  def init
    @session_no = 0
    @log = Log.new
    @log.status << [File.basename($0), :file]
    @differ = IRT::Differ
    @irt_on_diffs = true
    @tail_on_irt = false
    @autoload_helper_files = true
    Colorer.def_custom_styles :bold              => :bold,
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
                              :diff_b_color      => :green
    @os = get_os
    @copy_to_clipboard_command = case @os
                                 when :windows
                                   'clip'
                                 when :macosx
                                   'pbcopy'
                                 when :linux
                                   'xclip -selection c'
                                 when :unix
                                   'xclip -selection c'
                                 end
    @edit_command_format = case @os
                           when :windows
                             '%1$s'
                           when :macosx
                             'open -t %1$s'
                           when :linux
                             get_unix_linux_open_command
                           when :unix
                             get_unix_linux_open_command
                           end
    @vi_command_format = "vi -c 'startinsert' %1$s +%2$d"
    @nano_command_format = 'nano +%2$d %1$s'
  end

  def lib_path
    File.expand_path '../../lib', __FILE__
  end

  # this fixes a little imperfection of the YAML::dump method
  # which adds a space at the end of the class
  def IRT.yaml_dump(val)
    yml = "\n" + YAML.dump(val)
    yml.gsub(/ +\n/, "\n")
  end

private

  def get_unix_linux_open_command
    case ENV['DESKTOP_SESSION']
    when /kde/i
      'kde-open %1$s'
    when /gnome/i
      'gnome-open %1$s'
    end
  end

  def get_os
    case RbConfig::CONFIG['host_os']
    when /mswin|msys|mingw32|windows/i
      :windows
    when /darwin|mac os/i
      :macosx
    when /linux/i
      :linux
    when /solaris|bsd/i
      :unix
    else
      :unknown
    end
  end

end
IRT.init
