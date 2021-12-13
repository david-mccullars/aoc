require_relative '../solve'

EXAMPLE = <<-END
BFFFBBFRRR
FFFBBBFRRR
BBFFBBFRLL
END

class BoardingPasses

  def initialize(lines)
    @ids = lines.map do |line|
      line.tr('FBLR', '0101').to_i(2)
    end
  end

  def max_id
    @ids.max
  end

  def missing
    @ids.sort.each_cons(2).reduce(nil) do |missing, (x, y)|
      missing || (y - x > 1 && x + 1)
    end
  end

end

solve_with(BoardingPasses, EXAMPLE => 820) do |passes|
  passes.max_id
end

solve_with(BoardingPasses) do |passes|
  passes.missing
end
