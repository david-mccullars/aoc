require_relative '../solve'

EXAMPLE = <<-END
498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
END

class RegolithReservoir

  SAND_SOURCE = [500, 0]

  ROCK = '#'
  SAND = 'o'

  def initialize(lines)
    @grid = {}

    lines.map do |line|
      line.scan(/\d+/).map_i.each_slice(2).each_cons(2).map do |p1, p2|
        fill(p1, p2, ROCK)
      end
    end

    @rock_bottom = @grid.keys.map(&:last).max
  end

  def fill(p1, p2, value)
    Range.new(*[p1.first, p2.first].sort).each do |x|
      Range.new(*[p1.last, p2.last].sort).each do |y|
        @grid[[x, y]] = value
      end
    end
  end

  def add_floor(distance:)
    @floor = @rock_bottom + distance
    self
  end

  def drop_sand
    (0..).detect { !drop_one_sand }
  end

  def drop_one_sand
    tile = SAND_SOURCE

    until sand_clogged? || into_the_abyss?(tile)
      empty_tile = adjacent(tile).detect { |t| @grid[t].nil? }

      if empty_tile && !at_floor?(empty_tile)
        tile = empty_tile # Keep dropping
      else
        @grid[tile] = SAND
        return :added
      end
    end
  end

  def adjacent(tile)
    x, y = tile
    [[x, y+1], [x-1, y+1], [x+1, y+1]]
  end

  def sand_clogged?
    @floor && @grid[SAND_SOURCE]
  end

  def into_the_abyss?(tile)
    !@floor && tile.last >= @rock_bottom
  end

  def at_floor?(tile)
    @floor == tile.last
  end

end

solve_with(RegolithReservoir, EXAMPLE => 24) do |reservoir|
  reservoir.drop_sand
end

solve_with(RegolithReservoir, EXAMPLE => 93) do |reservoir|
  reservoir.add_floor(distance: 2).drop_sand
end
