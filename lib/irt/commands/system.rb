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
        eval <<-EOE
          def #{n}(*args)
            run_editor(:#{n}, *args)
          end
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
        command = if args.empty?
                    cmd_format = IRT.send("#{cmd}_command_format".to_sym)
                    raise NotImplementedError unless cmd_format
                    f, l = IRB.CurrentContext.file_line_pointers
                    sprintf cmd_format, f, l
                  else
                    "#{cmd} #{args * ' '}"
                  end
        system command
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
