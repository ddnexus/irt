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
        ENV['IRT_COMMAND'] = ENV['IRT_COMMAND'].sub(/#{Regexp.quote(file)}/, as_file)
        yield
      end
      true
    end

  end
end
