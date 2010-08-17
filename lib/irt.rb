require 'ostruct'
require 'irt/irb'
require 'irt/directives'
module IRT

  VERSION = '0.2.0'
   @session_lines = []

  class << self

    attr_accessor :irb_session, :lines, :line_no, :session_lines

    Colors = {:red => 31, :green => 32, :yellow => 33, :cyan => 36}

    def conf
      @conf ||= OpenStruct.new :color => true,
                               :open_irb_on_failure => true,
                               :file_lines_on_failure => 5,
                               :directive_map => { '"' => :desc,
                                                   '=>' => :test,
                                                   '>>' => :open_irb }
    end

    def directives
      IRT::Directives
    end

    def colorize(color, text)
      return text unless conf.color
      sprintf "\e[%dm%s\e[0m", Colors[color], text
    end

    def print_last_lines(q=IRT.conf.file_lines_on_failure)
      return unless q > 0
      start = line_no - q + 1
      start = 1 if start < 0
      self.lines[start..line_no].each_with_index do |l,i|
        ln = '%3d' % (i + start)
        puts colorize(:cyan, "#{ln}  #{l.strip}")
      end
      nil
    end

  end
end
