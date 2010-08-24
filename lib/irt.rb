require 'irt/irb'
require 'irt/history'
require 'irt/differ'
require 'irt/directives'

module IRT

  VERSION = '0.2.0'
  @history = History.new
  @differ = IRT::Differ
  @color = true
  @open_session_on_failure = true
  @show_tail_on_open_session = true
  @run_status = :file
  @skip_result_output = false

  class << self

    attr_accessor :color, :open_session_on_failure, :show_tail_on_open_session, :run_status, :skip_result_output
    attr_reader :history, :file, :differ

    Colors = {:red => 31, :green => 32, :yellow => 33, :magenta => 35, :cyan => 36}

    def directives
      IRT::Directives
    end

    def colorize(color, text)
      return text unless color
      sprintf "\e[%dm%s\e[0m", Colors[color], text
    end

    # this fixes a little imperfection of the YAML::dump method
    # which adds a space at the end of the class
    def yaml_dump(val)
      yml = "\n" + YAML::dump(val)
      yml.gsub(/\s+\n/, "\n")
    end

  end
end
