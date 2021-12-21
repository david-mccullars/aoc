module WithMemoizedMethods

  def memoize(name)
    orig_name = :"__unmemoized_#{name}__"
    alias_method orig_name, name

    @memoized_method_calls ||= {}
    @memoized_method_calls[name] ||= {}
    cache = @memoized_method_calls[name]

    define_method(name) do |*args|
      if cache.key?(args)
        cache[args]
      else
        cache[args] = send(orig_name, *args)
      end
    end
  end

end
