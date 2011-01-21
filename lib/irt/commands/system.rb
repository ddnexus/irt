module IRT
  module Commands
    module System

      def cat(*args)
        return system "cat #{IRB.CurrentContext.file_line_pointers.first}" if args.empty?
        system "cat #{args * ' '}"
      end

      def ls(*args)
        args = %w[.] if args.empty?
        system "ls #{args * ' '}"
      end

      def copy_lines
        copy_to_clipboard :print_lines
      end
      alias_method :cl, :copy_lines

      def copy_all_lines
        copy_to_clipboard :print_all_lines
      end
      alias_method :cll, :copy_all_lines

      %w[vi nano edit].each do |n|
        eval <<-EOE, binding, __FILE__, __LINE__+1
          def #{n}(*args)
            run_editor(:#{n}, *args)
          end
        EOE
        eval <<-EOE, binding, __FILE__, __LINE__+1
          def c#{n}(*args)
            copy_lines
            #{n} *args
          end
        EOE
      end
      alias_method :nn, :nano
      alias_method :ed, :edit
      alias_method :cnn, :cnano
      alias_method :ced, :cedit

    private

      def run_editor(cmd, *args)
        cmd_format = IRT.send("#{cmd}_command_format".to_sym)
        raise NotImplementedError unless cmd_format
        file, line = case
                      when args.empty?
                        IRB.CurrentContext.file_line_pointers
                      when args.first.to_s.match(/^\d+$/)
                        IRB.CurrentContext.backtrace_map[args.first]
                      when args.first.is_a?(Array)
                        args.first
                      when args.first.is_a?(Hash)
                        [args.first[:file], args.first[:line]]
                      else
                        args
                      end
        system sprintf(cmd_format, file, line)
      end

      def copy_to_clipboard(cmd)
        raise NotImplementedError, "No known copy_to_clipboard_command for this system." unless IRT.copy_to_clipboard_command
        lines_str = capture { send(cmd) }
        return unless lines_str.match(/\w/m)
        begin
          IO.popen(IRT.copy_to_clipboard_command, 'w') do |io|
            io.puts lines_str.strip
          end
          print lines_str
        rescue Exception
          raise NotImplementedError, "This system does not appear to support the \`#{IRT.copy_to_clipboard_command}\` command."
        end
      end

    end
  end
end
