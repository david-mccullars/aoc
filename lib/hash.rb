Hash.class_eval do

  def with_default(value)
    self.default = value
    self
  end

end
