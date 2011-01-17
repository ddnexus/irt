module IRT
  module Commands
    module Test

      extend self

      def add_desc(description)
        mode = IRB.CurrentContext.irt_mode
        raise NotImplementedError, "You cannot add a test description in #{mode} mode." unless mode == :interactive
        desc_str = %(desc "#{description}")
        IRB.CurrentContext.current_line = desc_str
        puts
        puts desc_str.interactive_color
        puts
      end
      alias_method :dd, :add_desc

      def add_test(description='')
        mode = IRB.CurrentContext.irt_mode
        raise NotImplementedError, "You cannot add a test in #{mode} mode." unless mode == :interactive
        context = IRB.CurrentContext
        last_value = context.last_value
        begin
          evaled = context.workspace.evaluate(self, last_value.inspect)
        rescue Exception
        end
        # the eval of the last_value.inspect == the last_value
        test_str = if evaled == last_value
                     # same as _? but easier to read for multiline strings without escaping chars
                     if last_value.is_a?(String) && last_value.match(/\n/)
                       str = last_value.split("\n").map{|l| l.inspect.sub(/^"(.*)"$/,'\1') }.join("\n")
                       last_value.match(/\n$/) ? "_eql? <<EOS\n#{str}\nEOS" : "_eql? %(#{str})"
                     else
                       "_eql?( #{last_value.inspect} )"
                     end
                   else # need YAML
                     "_yaml_eql? %(#{IRT.yaml_dump(last_value)})"
                   end
        desc_str = description.empty? ? '' : %(desc "#{description}"\n)
        str = desc_str + test_str
        context.current_line = str
        puts
        puts str.interactive_color
        puts
      end
      alias_method :tt, :add_test

    end
  end
end
