module IRT
  module Commands
    module Ri

      @@choices_map = {}

      def self.reset_choices_map
        @@choices_map = {}
      end

      def ri(arg, literal=false)
        ensure_session
        raise IRT::NotImplementedError, "No available ri_command_format for this system." unless IRT.ri_command_format
        case

        when arg.match(/^\d+$/)
          if @@choices_map.key?(arg)
            to_search = @@choices_map[arg]
          else
            raise IndexError, "No such method index -- [#{arg}]"
          end

        when literal
          if output = process_ri(arg)
            puts(output)
            return
          end

        when arg !~ /\./
          begin
            obj = eval arg, IRB.CurrentContext.workspace.binding
            to_search = obj.class
          rescue NameError
            if output = process_ri(arg)
              puts(output)
              return
            end
            raise
          end

        else
          segm = arg.split('.')
          to_search = segm.pop
          receiver = eval segm.join('.'), IRB.CurrentContext.workspace.binding
          raise NoMethodError, %(undefined method '#{to_search}' for #{receiver.inspect}:#{receiver.class}) \
            unless receiver.respond_to? to_search.to_sym
          meth = receiver.method(to_search.to_sym).inspect
          meth = meth.match(/^\#<Method: (.+)>$/)[1]
          if m = meth.match(/\((.+)\)(.+)/)
            to_search = m[1] + m[2]
          else
            to_search = meth
          end
        end

        puts process_ri(to_search) || 'Nothing found!'
      end

      def pri(arg)
        pager { ri arg }
      end

    private

      def process_ri(to_search)
        ri = `#{sprintf(IRT.ri_command_format, to_search)}`
        ri_problem unless $?.to_i == 0
        return if ri.match(/^(nil|No matching results found)$/)
        if m = ri.match(/^(-+.*Multiple choices:.*\n\n)(.+)/m)
          output, methods = m.captures
          IRT::Commands::Ri.reset_choices_map
          fmt = "%+7s  %s\n"
          methods.gsub(/\s+/, '').split(',').each_with_index do |m, i|
            @@choices_map[(i+1).to_s] = m
            output << sprintf( fmt, "#{i+1}", m )
          end
          output << "\n"
        else
          output = ri
        end
        output
      end

      def ri_problem
        ri_gem = IRT::RubyVersion >= '1.9.2' ? 'bri' : 'fastri'
        message = system("#{required} -v") ?
                    "Bad ri_command_format for this system." :
                    %(You must install the "#{ri_gem}" gem to use this command with ruby #{RUBY_VERSION}.)
        raise IRT::NotImplementedError, message
      end

    end
  end
end
