module IRT
  module Directives
    module Test

      @@test_no = 0
      @@passed_no = 0
      @@failed_no = 0
      @@error_no = 0

      # #: "
      def desc(arguments)
        @@last_desc = arguments
      end

      # #: =>
      def test(arguments)
        context = IRB.CurrentContext
        tno = '%3d' % @@test_no += 1
        d = @@last_desc || 'Test'
        @@last_desc = nil
        begin
          exp = context.workspace.evaluate(context, arguments, context.irb_path, IRT.line_no)
fail = lambda do |color, str, got|
  puts IRT.colorize color, %(#{tno}. #{str} #{d}
     < got: #{got}
     > expected: #{exp.inspect}
       at #{context.irb_path}:#{IRT.line_no} )
  IRT.print_last_lines
  open_irb if IRT.conf.open_irb_on_failure
end
          if exp == context.last_value
            @@passed_no += 1
            puts IRT.colorize(:green, "#{tno}. OK! #{d}")
          else
            @@failed_no += 1
            fail.call(:red, 'FAILED!', context.last_value.inspect)
          end
        rescue Exception => e
          @@error_no += 1
          fail.call(:yellow, 'ERROR!', exp, "#{e.class}: #{e.message}")
        end
      end

      def test_summary #:nodoc:
        if @@test_no == @@passed_no
          puts IRT.colorize( :green, "All #{@@test_no} tests passed.")
        else
          puts "#{@@test_no} tests: " +
               IRT.colorize(:green, "#{@@passed_no} passed, ") +
               IRT.colorize(:red, "#{@@failed_no} failed, ") +
               IRT.colorize(:yellow, "#{@@error_no} error.")
        end
      end

    end
  end
end
