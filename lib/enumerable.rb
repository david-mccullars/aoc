Enumerable.module_eval do

  def each_with_counter(default: 0, &block)
    each_with_object(Hash.new { default }, &block)
  end

end
