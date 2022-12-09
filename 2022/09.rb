require_relative '../solve'

EXAMPLE1 = <<-END
R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
END

EXAMPLE2 = <<-END
R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
END

class RopeBridge

  def initialize(lines)
    @instructions = lines.map(&:split)
    @tail_positions = Set.new
  end

  def simulate(knots:)
    rope = knots.times.map { [0, 0] }
    @instructions.each do |dir, amount|
      amount.to_i.times do
        adjust_rope(rope, dir)
        @tail_positions << rope.last.dup
      end
    end
    @tail_positions.size
  end

  def adjust_rope(knots, dir)
    knots[0] = knots[0].orthogonally_adjacent(dir)
    knots.reduce do |k1, k2|
      adjust_knot(k1, k2)
    end
  end

  def adjust_knot(k1, k2)
    dy = k1[0] - k2[0]
    dx = k1[1] - k2[1]

    if dy.abs > 1 || dx.abs > 1 # adjustment required
      k2[0] += dy.negative? ? -1 : 1 unless dy.zero?
      k2[1] += dx.negative? ? -1 : 1 unless dx.zero?
    end

    k2
  end

end

solve_with(RopeBridge, EXAMPLE1 => 13) do |bridge|
  bridge.simulate(knots: 2)
end

solve_with(RopeBridge, EXAMPLE2 => 36) do |bridge|
  bridge.simulate(knots: 10)
end
