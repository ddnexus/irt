require 'irb'
require 'irb/context'
require 'irt/irb/extensions'
module IRB #:nodoc:

  class Context

    alias :evaluate_with_set :evaluate
    attr_reader :line_no

    def evaluate(line, line_no)
      if IRT.run_status == :session
        evaluate_in_session(line, line_no)
      else
        evaluate_with_set(line, line_no)
      end
    end

    def evaluate_without_set(line, line_no)
      @line_no = line_no
      @workspace.evaluate(self, line, irb_path, line_no)
    end

    def evaluate_in_session(line, line_no)
      case line
      when /^\s*_\s*$/
        evaluate_without_set(line, line_no)
      # skip session history with prepended --
      when /^\s*--\s+(.*)$/
        evaluate_without_set($1, line_no)
      # skip session history and setting result for ignored commands
      when /^\s*(#{IRT.history.ignored_commands * '|'})\b/
        IRT.skip_result_output = true
        evaluate_without_set(line, line_no)
      # add to history ignored commands
      when /^\s*\+\+\s+(.*)$/
        evaluate_with_set($1, line_no)
        IRT.history.add_history_line $1
      # regular lines
      else
        begin # skip wrong lines from entering in history
          evaluate_with_set(line, line_no)
        rescue Exception => e
          raise e
        else
         IRT.history.add_line line
        end
      end
    end

  end

  class FileInputMethod
    def initialize(file)
      super
      @line_no = 0
      @io = open(file)
    end
    def gets
      print @prompt
      l = @io.gets
      IRT.history.add_line l, (@line_no += 1)
      l
    end
  end

  class IRB::Irb
    alias :do_output_value :output_value
    def output_value
      if IRT.skip_result_output
        IRT.skip_result_output = false
        return
      end
      do_output_value
    end
  end

end
