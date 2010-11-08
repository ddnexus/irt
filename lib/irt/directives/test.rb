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
          puts "All #{@@test_no} tests passed.".ok.bold
        else
          puts "#{@@test_no} tests: ".bold +
               "#{@@passed_no} passed, ".ok.bold +
               "#{@@failed_no} failed, ".failed.bold +
               "#{@@error_no} error.".error.bold
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
            puts "#{tno}. OK!".ok.bold + " #{d}".ok
          else
            @@failed_no += 1
            puts "#{tno}. FAILED!".failed.bold + %( #{d}
     at #{context.irb_path}:#{context.line_no}
).failed
            puts IRT.differ.new(expected, got, kind).output
            open_session if IRT.open_session_on_failure
          end
        rescue Exception => e
          exit(1) if IRT.run_status == :full_exit
          @@error_no += 1
          puts "#{tno}. ERROR!".error.bold %( #{d}
     #{e.class}: #{e.message}
     at #{context.irb_path}:#{context.line_no}
).error
          open_session if IRT.open_session_on_failure
        end
      end

    end
  end
end
