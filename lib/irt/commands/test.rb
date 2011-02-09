module IRT
  module Commands
    module Test

      extend self

      def add_desc(description)
        mode = context.irt_mode
        raise IRT::SessionModeError, "You cannot add a test description in #{mode} mode." unless mode == :interactive
        desc_str = %(desc "#{description}")
        context.current_line = desc_str
        puts
        puts IRT.dye(desc_str, :interactive_color)
        puts
      end
      alias_method :dd, :add_desc

      def add_test(description='')
        mode = context.irt_mode
        raise IRT::SessionModeError, "You cannot add a test in #{mode} mode." unless mode == :interactive
        last_value = context.last_value
        begin
          evaled = context.workspace.evaluate(self, last_value.inspect)
        rescue Exception
        end
        # the eval of the last_value.inspect == the last_value
        test_str = if evaled == last_value
                     # same as _? but easier to read for multiline strings
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
        puts IRT.dye(str, :interactive_color)
        puts
      end
      alias_method :tt, :add_test

      def save_as(path)
        path = File.expand_path(path)
        if File.exists?(path)
          return if IRT.prompter.no? %(Do you want to overwrite "#{path}"?), :hint => '[y|<enter=n]', :default => 'n'
        end
        dirname = File.dirname(path)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
        cp IRT.irt_file, path
        ENV['IRT_COMMAND'] = ENV['IRT_COMMAND'].sub(/#{Regexp.quote(IRT.irt_file)}/, path)
        rerun
      end
      alias_method :sa, :save_as

    end
  end
end
