module IRT
  module Directives
    module Session

      def add_desc(description)
        add_history_line %(desc "#{description})
      end

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
          add_history_line "test_value_eql? #{last_value.inspect}"
        else # need YAML
          add_history_line "test_yaml_eql? %(#{IRT.yaml_dump(last_value)})"
        end
        IRT.history.add_line  # add an empty line for readability
      end

      def add_comment(comment)
        add_history_line "# #{comment}"
      end

      private
      def add_history_line(line)
        IRT.history.add_history_line line
      end

    end
  end
end
