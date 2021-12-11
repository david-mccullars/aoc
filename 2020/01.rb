require_relative '../solve'

EXAMPLE = <<-END
  1721
  979
  366
  299
  675
  1456
END

def find_2020_combo(numbers, size)
  numbers.combination(size).detect do |a|
    a.sum == 2020
  end.flatten.reduce(&:*)
end

solve_with_numbers(EXAMPLE => 514579) do |numbers|
  find_2020_combo(numbers, 2)
end

solve_with_numbers(EXAMPLE => 241861950) do |numbers|
  find_2020_combo(numbers, 3)
end
