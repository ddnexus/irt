module IRT
  module Directives
    module History

      def history(lines=IRT.history.tail_size)
        IRT.history.print_tail lines
      end
      alias :h :history

      def history_remove_last
        IRT.history.remove_last_line
      end
      alias :hrl :history_remove_last

      def history_clear
        IRT.history.clear_lines
      end

      def add_desc(description)
        IRT.history.insert_desc_line %(desc "#{description}")
      end
      alias :ad :add_desc

      def add_test(description=nil)
        context = IRB.CurrentContext
        last_value = context.last_value
        add_desc(description) if description
        begin
          evaled = context.workspace.evaluate(self, last_value.inspect)
        rescue Exception
        end
        # the eval of the last_value.inspect == the last_value
        if evaled == context.last_value
          IRT.history.add_session_line "test_value_eql? #{last_value.inspect}"
        else # need YAML
          IRT.history.add_session_line "test_yaml_eql? %(#{IRT.yaml_dump(last_value)})"
        end
        IRT.history.lines << IRT::History::EmptyLine.new  # add an empty line for readability
      end
      alias :at :add_test

      def add_comment(comment)
        IRT.history.add_session_line "# #{comment}"
      end
      alias :ac :add_comment

      def add_empty_line
        IRT.history.add_empty_line
      end
      alias :ael :add_empty_line

    end
  end
end
