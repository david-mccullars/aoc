Enumerable.module_eval do

  def each_with_counter(default: 0, &block)
    each_with_object(Hash.new { default }, &block)
  end

  def first!
    raise "Size is not 1: #{to_a.inspect}" if size != 1
    first
  end

end
