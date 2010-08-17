module IRT

  VERSION = '0.1.0'
  Color = { true =>  { :green => %{\e[32m%s\e[0m}, :red =>  %{\e[31m%s\e[0m} },
            false => { :green => '%s', :red => '%s' } }

    def IRT.init(colors=true)
      @colors = colors
      @test_no = 0
      @passed_no = 0
      @failed_no = 0
      IRB.conf[:PROMPT_MODE] = :SIMPLE
      IRB.conf[:ECHO] = false
      IRB.conf[:VERBOSE] = false
      IRB.conf[:AT_EXIT] = [proc{IRT.test_summary}]

      IRB::Context.class_eval do
        alias :evaluate_without_directives  :evaluate

        def evaluate(line, line_no)
          ln = line_no
          line.split($/).each do |l|
            if l =~ /^\s*#:\s*([\S]+)(?:\s+(.*))*/
              action = IRT::Directives::Map[$1] || $1
              arguments = $2 && $2.strip
              begin
                IRT.send action.to_sym, self, arguments, ln
              rescue NoMethodError
                puts "NoMethodError: Undefined directive :#{action}\n        from #{irb_path}:#{line_no}"
              end
            end
            ln += 1
          end
          evaluate_without_directives(line, line_no)
        end

      end
      extend Directives
    end

    def IRT.test_summary
      if @failed_no > 0
        puts Color[@colors][:red] % "#{@test_no} tests: #{@passed_no} passed, #{@failed_no} failed."
      else
        puts Color[@colors][:green] % "All #{@test_no} tests passed."
      end
    end

  module Directives
    Map = { '"' => :desc, '=>' => :test, '>>' => :start_irb }

    # #: "
    def desc(context, arguments, line_no)
      @last_desc = arguments
    end

    # #: =>
    def test(context, arguments, line_no)
      tn = '%3d' % @test_no += 1
      d = @last_desc || 'Test'
      @last_desc = nil
      begin
        exp = eval(arguments)
      rescue Exception => e
        puts %(#{e.class.name}: #{e.message}\n        from #{context.irb_path}:#{line_no})
      end
      if exp == context.last_value
        @passed_no += 1
        puts Color[@colors][:green] % "#{tn}. OK! #{d}"
      else
        @failed_no += 1
        puts Color[@colors][:red] % %(#{tn}. FAILED! #{d}
     > expected: #{exp.inspect}
     < got: #{context.last_value.inspect}
     from #{context.irb_path}:#{line_no} )
      end
    end

    # #: >>
    def start_irb(context, arguments, line_no)
      IRB.conf[:ECHO] = true
      irb = IRB::Irb.new(context.workspace)
      catch(:IRB_EXIT) do
        irb.eval_input
      end
    end

  end

end
