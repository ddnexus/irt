class Object
  def object_methods
    methods - self.class.methods
  end
end
