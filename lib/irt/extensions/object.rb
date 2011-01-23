class Object

  def own_methods
    methods - self.class.methods
  end

end
