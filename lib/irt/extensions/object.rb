require 'tempfile'

class Object

  def own_methods
    methods - self.class.methods
  end

  IRT::EDITORS.each_pair do |name, short|
    # with IDEs we cannot come back after editing
    next if name == :edit

    define_method(name) do
      t = Tempfile.new(['', '.yml'])
      t << to_yaml
      t.flush
      IRT.edit_with(name, t.path)
      return self unless File.exists?( t.path )
      obj = YAML::load_file t.path
      t.close
      obj
    end

    alias_method short, name if short

  end

end
