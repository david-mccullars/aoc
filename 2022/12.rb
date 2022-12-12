require_relative '../solve'
require 'parallel'

EXAMPLE = <<-END
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
END

class HillClimbing

  include DijkstraFast::ShortestPath

  def initialize(grid)
    grid[@start = grid.key('S')] = 'a'
    grid[@end = grid.key('E')] = 'z'
    @grid = grid.transform_values { _1.ord - 'a'.ord }
  end

  def connections(u)
    u.orthogonally_adjacent.each do |v|
      yield v, 1 if @grid[v] && @grid[v] <= @grid[u] + 1
    end
  end

  def shortest_from_start
    shortest_distance(@start, @end)
  end

  def overall_shortest
    possible_starts = @grid.select { |_, v| v.zero? }.keys
    Parallel.map(possible_starts, in_processes: 16, progress: true) do |alt_start|
      shortest_distance(alt_start, @end) rescue Float::INFINITY
    end.min
  end

end

solve_with_grid_of_letters(clazz: HillClimbing, EXAMPLE => 31, &:shortest_from_start)
solve_with_grid_of_letters(clazz: HillClimbing, EXAMPLE => 29, &:overall_shortest)
