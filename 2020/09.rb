require_relative '../solve'

EXAMPLE = <<-END
35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576
END

class XmasEncoding

  def initialize(numbers)
    @numbers = numbers
    @preamble_size = numbers.size == EXAMPLE.lines.size ? 5 : 25
  end

  def first_invalid
    @numbers.each_cons(@preamble_size + 1).detect do |*previous, n|
      previous.product(previous).none? do |x, y|
        x != y && x + y == n
      end
    end&.last
  end

  def first_weakness
    invalid = first_invalid
    each_contiguous_sums(@numbers.index(invalid)) do |sums, count|
      if invalid_index = sums.index(invalid)
        return @numbers[invalid_index .. invalid_index + count]
      end
    end

    raise 'No weakness found!'
  end

  def each_contiguous_sums(max_count)
    previous = @numbers.first(max_count)
    sums = previous.dup

    max_count.times do |count|
      previous.shift
      sums.pop
      sums = sums.zip(previous).map(&:sum)
      yield sums, count + 1
    end

    nil
  end

end

solve_with_numbers(clazz: XmasEncoding, EXAMPLE => 127) do |xmas|
  xmas.first_invalid
end

solve_with_numbers(clazz: XmasEncoding, EXAMPLE => 62) do |xmas|
  xmas.first_weakness.minmax.sum
end
