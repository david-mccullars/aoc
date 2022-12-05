module WithMemoizedMethods

  def memoize(name)
    orig_name = :"__unmemoized_#{name}__"
    alias_method orig_name, name

    define_method(name) do |*args|
      @memoized_method_calls ||= {}
      @memoized_method_calls[name] ||= {}
      cache = @memoized_method_calls[name]

      if cache.key?(args)
        cache[args]
      else
        cache[args] = send(orig_name, *args)
      end
    end
  end

end
