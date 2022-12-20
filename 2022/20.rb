require_relative '../solve'

EXAMPLE = <<-END
1
2
-3
3
-2
0
4
END

# Like The Highlander, there can only be one!
class UniqueWrapper

  attr_accessor :value

  def initialize(value)
    @value = value
  end

end

class GrovePositioningSystem

  DECRYPTION_KEY = 811589153

  def initialize(numbers)
    @numbers = numbers.map { |n| UniqueWrapper.new(n) }
    @mixed = @numbers.dup
    @zero = @numbers[numbers.index(0)]
  end

  def apply_decryption_key
    @numbers.each do |n|
      n.value *= DECRYPTION_KEY
    end
    self
  end

  def mix(times = 1.times)
    times.each do
      @numbers.each do |unique|
        i = @mixed.index(unique)
        @mixed.rotate!(i)
        @mixed.shift
        @mixed.rotate!(unique.value)
        @mixed.unshift(unique)
      end
    end
    self
  end

  def grove_coordinate_sum
    zero_idx = @mixed.index(@zero)
    [1000, 2000, 3000].map do |offset|
      @mixed[(zero_idx + offset) % @mixed.size].value
    end.sum
  end

end

solve_with_numbers(clazz: GrovePositioningSystem, EXAMPLE => 3) do |gps|
  gps.mix.grove_coordinate_sum
end

solve_with_numbers(clazz: GrovePositioningSystem, EXAMPLE => 1623178306) do |gps|
  gps.apply_decryption_key.mix(10.times).grove_coordinate_sum
end
