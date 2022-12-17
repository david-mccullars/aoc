require_relative '../solve'

EXAMPLE = <<-END
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
END

class Valve < Struct.new(:name, :flow_rate, :tunnels)

  extend HasFormat
  has_format "Valve {{name}} has flow rate={{i:flow_rate}}; tunnels? leads? to valves? {{csv:tunnels}}"

end

class ProboscideaVolcanium

  extend WithMemoizedMethods
  extend HasFormat
  has_format [Valve]

  def initialize(valves)
    valve_ids = valves.map(&:name).map.with_index.to_h

    @start_valve = valve_ids.fetch("AA")
    @flow_rates = valves.map(&:flow_rate)
    @distances = Array.new(valves.size) { Array.new(valves.size) { Float::INFINITY } }

    valves.each_with_index do |v, i|
      @distances[i][i] = 0
      valve_ids.values_at(*v.tunnels).each do |j|
        @distances[i][j] = 1
      end
    end

    (0...valves.size).to_a.permutation(3) do |i, j, k|
      alt_dist = @distances[k][i] + @distances[i][j]
      @distances[k][j] = alt_dist if alt_dist < @distances[k][j]
    end
  end

  def max_pressure(worker, minutes, valve, closed_valves)
    options = closed_valves.filter_map do |valve2|
      next if @distances[valve][valve2] >= minutes

      minutes2 = minutes - @distances[valve][valve2] - 1
      pressure = max_pressure(worker, minutes2, valve2, closed_valves - [valve2])
      pressure + @flow_rates[valve2] * minutes2
    end
    if worker == :elephant
      options << max_pressure(:me, 26, @start_valve, closed_valves)
    end
    options.max.to_i
  end

  memoize :max_pressure

  def valves_to_visit
    @flow_rates.filter_map.with_index { |rate, i| i if rate > 0 }
  end

  def max_pressure_solo
    max_pressure(:me, 30, @start_valve, valves_to_visit)
  end

  def max_pressure_with_an_elephant_friend
    max_pressure(:elephant, 26, @start_valve, valves_to_visit)
  end

end

solve_with_format(ProboscideaVolcanium, EXAMPLE => 1651) do |pv|
  pv.max_pressure_solo
end

solve_with_format(ProboscideaVolcanium, EXAMPLE => 1707) do |pv|
  pv.max_pressure_with_an_elephant_friend
end
