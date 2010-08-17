require 'irb'
require 'irb/context'
require 'irt/irb/extensions'
module IRB #:nodoc:

  conf[:PROMPT_MODE] = :NULL
  conf[:ECHO] = false
  conf[:VERBOSE] = false
  conf[:AT_EXIT] = [proc{IRT::Directives.test_summary}]

  class Context
    alias :evaluate_without_directives :evaluate
    def evaluate(line, line_no)
      if IRT.irb_session
        begin
          evaluate_without_directives(line, line_no)
        rescue Exception => e
          raise e
        else
          IRT.session_lines << line
        end
      else
        IRT.line_no = line_no
        line.split($/).each do |l|
          if l =~ /^\s*#:\s*([\S]+)(?:\s+(.*))*/
            action = IRT.conf.directive_map[$1] || $1
            arguments = $2 && $2.strip
            IRT.directives.send action.to_sym, arguments
          end
          IRT.line_no += 1
        end
        evaluate_without_directives(line, line_no)
      end
    end
  end

  class FileInputMethod
    def initialize(file)
      super
      IRT.lines = [nil]
      @io = open(file)
    end

    def gets
      print @prompt
      l = @io.gets
      IRT.lines << l
      l
    end
  end

end
