module IRT
  module Directives
    module Test

      @@test_no = 0
      @@passed_no = 0
      @@failed_no = 0
      @@error_no = 0
      @@last_desc = nil

      def desc(arguments)
        @@last_desc = arguments
      end

      def test_value_eql?(expected)
        got = IRB.CurrentContext.last_value
        run_test(expected, got, :value)
      end

      def test_yaml_eql?(expected)
        got = IRT.yaml_dump(IRB.CurrentContext.last_value)
        run_test(expected, got, :yaml)
      end

      def test_summary #:nodoc:
        return unless @@test_no > 0
        if @@test_no == @@passed_no
          puts IRT.colorize( :green, "All #{@@test_no} tests passed.")
        else
          puts "#{@@test_no} tests: " +
               IRT.colorize(:green, "#{@@passed_no} passed, ") +
               IRT.colorize(:red, "#{@@failed_no} failed, ") +
               IRT.colorize(:yellow, "#{@@error_no} error.")
        end
    end

  private

      def run_test(expected, got, kind)
        context = IRB.CurrentContext
        tno = '%3d' % @@test_no += 1
        d = @@last_desc || 'Test'
        @@last_desc = nil
        begin
          if expected == got
            @@passed_no += 1
            puts IRT.colorize(:green, "#{tno}. OK! #{d}")
          else
            @@failed_no += 1
            puts IRT.colorize :red, %(#{tno}. FAILED! #{d}
     at #{context.irb_path}:#{context.line_no}
)
            puts IRT.differ.new(expected, got, kind).output
            open_session if IRT.open_session_on_failure
          end
        rescue Exception => e
          @@error_no += 1
          puts IRT.colorize :yellow, %(#{tno}. ERROR! #{d}
     #{e.class}: #{e.message}
     at #{context.irb_path}:#{context.line_no}
)
          open_session if IRT.open_session_on_failure
        end
      end

    end
  end
end
