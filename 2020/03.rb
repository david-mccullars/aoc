require_relative '../solve'

EXAMPLE = <<-END
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
END

class TogogganRun

  def initialize(lines)
    @trees = lines.map do |line|
      line.chars.map { |c| c == '#' }
    end
  end

  def tree?(x, y)
    mod = @trees[y].size
    @trees[y][x % mod]
  end

  def run(x_delta, y_delta)
    x, y = 0, 0
    trees_encountered = 0
    until y >= @trees.size
      trees_encountered += 1 if tree?(x, y)
      x += x_delta
      y += y_delta
    end
    trees_encountered
  end

  def run_multi(*deltas)
    deltas.each_slice(2).map do |delta|
      run(*delta)
    end
  end

end

solve_with(TogogganRun, EXAMPLE => 7) do |toboggan|
  toboggan.run(3, 1)
end

solve_with(TogogganRun, EXAMPLE => 336) do |toboggan|
  toboggan.run_multi(
    1, 1,
    3, 1,
    5, 1,
    7, 1,
    1, 2,
  ).reduce(&:*)
end
