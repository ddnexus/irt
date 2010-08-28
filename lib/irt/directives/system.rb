module IRT
  module Directives
    module System

      def cat(*files)
        system "cat #{files * ' '}"
      end

      def git(command, options='')
        system "git #{command} #{options}"
      end

    end
  end
end
