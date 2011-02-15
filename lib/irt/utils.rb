module IRT
  module Utils

    extend self

    def save_as(file, as_file_local, prompter)
      as_file = File.expand_path(as_file_local)
      if File.exists?(as_file)
        return false if prompter.no? %(Do you want to overwrite "#{as_file}"?), :hint => '[y|<enter=n]', :default => 'n'
      end
      dirname = File.dirname(as_file)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      FileUtils.cp file, as_file
      if prompter.yes? %(Do you want to run the file "#{as_file_local}" now?)
        yield
      end
      true
    end

    # this will create a tmp file and start IRB
    # but it will be left in file mode at EOF (sort of irt-standby)
    def load_irt
      return if IRT.initialized
      ARGV.clear
      require 'tempfile'
      tmp_file = Tempfile.new(['', '.irt'])
      tmp_file << "\n" # one empty line makes irb of 1.9.2 happy
      tmp_file.flush
      ARGV.push tmp_file.path
      IRB.start
    end

  end
end
