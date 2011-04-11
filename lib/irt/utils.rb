if RUBY_PLATFORM == "java"
  require 'jruby'
  JRuby.runtime.instance_config.run_ruby_in_process = false
end

require 'irt/prompter'

module IRT

  def cli?
    !!ENV['IRT_COMMAND']
  end

  def lib_path
    File.expand_path '../../../lib', __FILE__
  end

  # this fixes a little imperfection of the YAML::dump method
  # which adds a space at the end of the class
  def yaml_dump(val)
    yml = "\n" + YAML.dump(val)
    yml.gsub(/ +\n/, "\n")
  end

  module Utils

    def create_tmp_file()
      require 'tempfile'
      tmp_file = Tempfile.new(['', '.irt'])
      tmp_file << "\n" # one empty line makes irb of 1.9.2 happy
      tmp_file.flush
      # ENV used because with IRT.cli? 2 different processes need to access the same path
      ENV['IRT_TMP_PATH'] = tmp_file.path
      at_exit { check_save_tmp_file(tmp_file) }
      ENV['IRT_TMP_PATH']
    end

    def save_as(file_path, source_path=IRT.irt_file, tmp=false)
      new_file_path = File.expand_path(file_path)
      if File.exists?(new_file_path)
        return false if IRT::Prompter.no? %(Do you want to overwrite "#{new_file_path}"?), :hint => '[y|<enter=n]', :default => 'n'
      end
      dirname = File.dirname(new_file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
      FileUtils.cp source_path, new_file_path
      ask_run_new_file new_file_path, source_path, tmp
    end

    def edit_with(editor, file, line=nil)
      cmd_format = IRT.send("#{editor}_command_format".to_sym)
      raise IRT::NotImplementedError, "#{cmd}_command_format missing" unless cmd_format
      system sprintf(cmd_format, file, line||0)
    end

    def version
      @version ||= File.read(File.expand_path('../../../VERSION', __FILE__)).strip
    end

    def copyright
      @copyrignt ||= Dye.dye "irt #{version} (c) 2010-2011 Domizio Demichelis", :blue, :bold
    end

  private

    def ask_run_new_file(new_file_path, source_path, tmp)
      if IRT::Prompter.yes?( %(Do you want to run the file "#{File.basename(new_file_path)}" now?) )
        # if we are saving a tmp_file from a save_as command (not from an at_exit block)
        if ENV['IRT_TMP_PATH'] && IRT.respond_to?(:irt_file) && IRT.irt_file == Pathname.new(ENV['IRT_TMP_PATH']).realpath
          ENV.delete('IRT_TMP_PATH')
          # reset tmp file content so check_save_tmp_file will be skipped
          File.open(source_path, 'w'){|f| f.puts "\n"}
        end
        if tmp && IRT.cli?
          ENV['IRT_COMMAND'] = ENV['IRT_COMMAND'].sub(/#{Regexp.quote(source_path)}/, new_file_path)
          exec ENV['IRT_COMMAND']
        else
          IRT::Session.run_file new_file_path
        end
      end
    end

    def check_save_tmp_file(tmp_file)
      if tmp_file.size > 1
        IRT::Prompter.yes? %(The template file has been modified, do you want to save it?) do
          IRT::Prompter.choose %(Enter the file path to save:), /[\w0-9_]/ do |file_path|
            save_as(file_path, tmp_file.path, tmp=true)
          end
        end
      end
    end

  end

  extend self
  extend Utils

end
