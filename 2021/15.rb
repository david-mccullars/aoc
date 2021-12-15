require_relative '../solve'

EXAMPLE = <<-END
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
END

class Chiton

  include DijkstraFast::ShortestPath

  def initialize(grid)
    @grid = grid
  end

  def expand!(factor:)
    height, width = @grid.keys.sort.max.map { |i| i + 1 }
    new_grid = {}
    @grid.each do |(y, x), v|
      factor.times do |i|
        factor.times do |j|
          v2 = ((v + i + j - 1) % 9) + 1
          new_grid[[height * i + y, width * j + x]] = v2
        end
      end
    end
    @grid = new_grid
    self
  end

  def adjacent(y, x)
    [
      [y + 1, x],
      [y - 1, x],
      [y, x + 1],
      [y, x - 1],
    ]
  end

  def connections(u)
    adjacent(*u).each do |v|
      v_risk = @grid[v] or next
      yield v, v_risk
    end
  end

  def shortest
    shortest_distance(*@grid.keys.minmax, progress: true)
  end

end

solve_with_grid_of_numbers(clazz: Chiton, EXAMPLE => 40) do |chiton|
  chiton.shortest
end

solve_with_grid_of_numbers(clazz: Chiton, EXAMPLE => 315) do |chiton|
  chiton.expand!(factor: 5).shortest
end
