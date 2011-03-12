module IRT
  module Commands
    module Edit

      def copy_lines
        ensure_session
        copy_to_clipboard :print_lines
      end
      alias_method :cl, :copy_lines

      def copy_all_lines
        ensure_session
        copy_to_clipboard :print_all_lines
      end
      alias_method :cll, :copy_all_lines

      [:vi, :nano, :emacs, :edit].each do |n|

        define_method(n) do |*args|
          ensure_session
          run_editor(n, *args)
        end

        define_method(:"c#{n}") do |*args|
          ensure_session
          copy_lines
          send n, *args
        end

      end
      alias_method :nn, :nano
      alias_method :ed, :edit
      alias_method :em, :emacs
      alias_method :cnn, :cnano
      alias_method :ced, :cedit
      alias_method :cem, :cemacs

    private

      def run_editor(cmd, *args)
        cmd_format = IRT.send("#{cmd}_command_format".to_sym)
        raise IRT::NotImplementedError, "#{cmd}_command_format missing" unless cmd_format
        arg = args.first if args.size == 1
        file, line = case
                     when args.empty?
                       context.file_line_pointers
                     when arg.is_a?(Integer)
                       if context.backtrace_map.key?(arg)
                         context.backtrace_map[arg]
                       else
                         raise IRT::IndexError, "No such backtrace index -- [#{arg}]"
                         return
                       end
                     when arg.is_a?(Array)
                       arg
                     when arg.is_a?(Hash)
                       [arg[:file], arg[:line]]
                     when arg.is_a?(String) && m = arg.match(/(?:([\w]+) \(([\w.]+)\))? ?([+\w\/\n.-]+):(\d+)/m)
                        gem, vers, f, l = m.captures
                        if gem
                          Gem.path.each do |p|
                            gp = File.join(p, 'gems', "#{gem}-#{vers}", f)
                            break [gp, l] if File.exist?(gp)
                          end
                        else
                          [f.gsub("\n", ''), l]
                        end
                     else
                       args
                     end
        system sprintf(cmd_format, file, line||0)
      end

      def copy_to_clipboard(cmd)
        raise IRT::NotImplementedError, "No known copy_to_clipboard_command for this system." \
          unless IRT.copy_to_clipboard_command
        lines_str = capture { send(cmd) }
        return unless lines_str.match(/\w/m)
        begin
          IO.popen(IRT.copy_to_clipboard_command, 'w') do |io|
            io.puts lines_str.strip
          end
          print lines_str
        rescue Exception
          raise IRT::NotImplementedError, "This system does not appear to support the \`#{IRT.copy_to_clipboard_command}\` command."
        end
      end

    end
  end
end
