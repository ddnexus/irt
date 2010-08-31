begin
  require 'ap'
rescue LoadError
end

require 'pp'
require 'irb/completion'
require 'irt/extensions'
require 'colorer'
require 'irt/irb'
require 'irt/history'
require 'irt/differ'
require 'irt/directives'

module IRT

  VERSION = '0.7.1'

  class << self

    attr_accessor :open_session_on_failure, :show_tail_on_open_session, :skip_result_output
    attr_reader :run_status, :history, :file, :differ, :color

    def init
      @history = History.new
      @differ = IRT::Differ
      Colorer.color = true
      @open_session_on_failure = true
      @show_tail_on_open_session = true
      self.run_status = :file
      @skip_result_output = false
      Colorer.define_styles :bold => [:bold],
                            :reversed => [:reversed],
                            :failed => [ :red ],
                            :ok => [ :green],
                            :error => [:yellow ],
                            :ok_text => [ :green ],
                            :expected => [ :green ],
                            :current => [ :red ],
                            :header => [ :black, :oncyan ],
                            :message => [ :yellow ],
                            :session_line => [ :magenta ],
                            :file_line => [ :cyan ],
                            :running_file => [ :bold, :reversed ],
                            :restart => [ :bold, :yellow, :reversed ]
    end

    def run_status=(status)
      case status
      when :file
        IRB.conf[:ECHO] = false
      when :session
        IRB.conf[:ECHO] = true
      end
      @run_status = status
    end

    def color=(bool)
      Colorer.color = bool
    end

    def directives
      IRT::Directives
    end

    # this fixes a little imperfection of the YAML::dump method
    # which adds a space at the end of the class
    def yaml_dump(val)
      yml = "\n" + YAML::dump(val)
      yml.gsub(/\s+\n/, "\n")
    end

    def puts_running(file)
      puts " *** Running #{file} *** ".running_file
    end

  end
end
IRT.init
