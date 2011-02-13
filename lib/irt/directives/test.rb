module IRT
  module Directives
    module Test
      extend self

      @@tests = 0
      @@oks = 0
      @@diffs = 0
      @@errors = 0
      @@last_desc = nil

      def desc(description)
        @@last_desc = description
      end

      def _eql?(saved)
        actual = IRB.CurrentContext.last_value
        run_test(saved, actual, :value)
      end
      alias_method :test_value_eql?, :_eql?
      alias_method :last_value_eql?, :_eql?

      def _yaml_eql?(saved)
        actual = IRT.yaml_dump(IRB.CurrentContext.last_value)
        run_test(saved, actual, :yaml)
      end
      alias_method :last_yaml_eql?, :_yaml_eql?
      alias_method :test_yaml_eql?, :_yaml_eql?

      def test_summary #:nodoc:
        return unless @@tests > 0
        if @@tests == @@oks
          str = @@tests == 1 ? " The TEST is OK! " : " All #{@@tests} TESTs are OK! "
          puts IRT.dye(str, :ok_color, :bold)
        else
          puts IRT.dye("#{@@tests} TEST#{'s' unless @@tests == 1}: ", :bold) +
               IRT.dye("#{@@oks} OK#{'s' unless @@oks == 1}, ", :ok_color, :bold) +
               IRT.dye("#{@@diffs} DIFF#{'s' unless @@diffs == 1}, ", :diff_color, :bold) +
               IRT.dye("#{@@errors} ERROR#{'s' unless @@errors == 1}.", :error_color, :bold)
        end
    end

    def load_helper_files
      return unless IRT.autoload_helper_files
      irt_file_path = Pathname.new($0).realpath
      container_path = Pathname.getwd.parent
      down_path = irt_file_path.relative_path_from container_path
      down_path.dirname.descend do |p|
       helper_path = container_path.join(p, 'irt_helper.rb')
       begin
         require helper_path
       rescue LoadError
       end
      end
    end

  private

      def run_test(saved, actual, kind)
        context = IRB.CurrentContext
        tno = '%3d' % @@tests += 1
        d = @@last_desc || 'Test'
        @@last_desc = nil
        begin
          if saved == actual
            @@oks += 1
            puts IRT.dye("#{tno}. OK!", :ok_color, :bold) + IRT.dye(" #{d}", :ok_color)
          else
            @@diffs += 1
            puts IRT.dye("#{tno}. DIFFS!", :diff_color, :bold) + IRT.dye(" #{d}\n     ", :diff_color) +
                 IRT.dye(" at #{context.irb_path}: #{context.last_line_no} ", :file_color, :reversed, :bold)
            puts IRT::Differ.new(saved, actual, kind).output
            IRT::Session.enter(:interactive) if IRT.irt_on_diffs
          end
        rescue Exception
          @@errors += 1
          puts IRT.dye("#{tno}. ERROR! ", :error_color, :bold) + IRT.dye(d, :error_color)
          raise
        end
      end

    end
  end
end
