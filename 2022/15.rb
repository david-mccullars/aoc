require_relative '../solve'
require 'facets'
require 'parallel'

EXAMPLE = <<-END
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
END

class BeaconExclusionZone

  def initialize(lines)
    pairs = lines.map do |line|
      line.scan(/-*\d+/).map_i.each_slice(2).to_a
    end.to_h
    @beacons = pairs.values.uniq
    @sensors = pairs.map do |sensor, beacon|
      [sensor, md(sensor, beacon)]
    end.to_h

    @is_example = @sensors.size < 20
    @interesting_row = @is_example ? 10 : 2000000
    @max_scan_range = @is_example ? 20 : 4000000
  end

  def scan_interesting_row
    beacons_on_row = @beacons.count { |_, y| y == @interesting_row }

    ranges = Parallel.map(@sensors, progress: !@is_example) do |sensor, beacon_distance|
      boundary_around(sensor, beacon_distance).filter_map do |x, y|
        x if y == @interesting_row
      end.then do |x1, x2|
        Range.new(x1, x2) if x1 && x2
      end
    end.compact

    Range.combine(*ranges).map(&:size).sum - beacons_on_row
  end

  def find_distress_signal
    Parallel.map(@sensors, progress: !@is_example) do |sensor, beacon_distance|
      # Consider locations one distance further than its beacon
      scan_distance = beacon_distance + 1
      boundary_around(sensor, scan_distance).detect do |candidate|
        within_signal_range?(candidate) && hidden_from_sensors?(candidate)
      end&.then do |found|
        raise Parallel::Break, found
      end
    end
  end

  def within_signal_range?(position)
    position.all? { |v| v >= 0 && v <= @max_scan_range }
  end

  def hidden_from_sensors?(position)
    @sensors.none? do |sensor, beacon_distance|
      md(sensor, position) <= beacon_distance
    end
  end

  def boundary_around(sensor, d)
    sx, sy = sensor
    Enumerator.new do |e|
      d.times do |dy|
        [sx - d + dy, sx + d - dy].each do |cx|
          [sy - dy, sy + dy].each do |cy|
            e << [cx, cy]
          end
        end
      end
    end
  end

  def count_row(y)
    @ranges[y].map(&:size).sum + 1
  end

  def md(a, b)
    (a.first - b.first).abs + (a.last - b.last).abs
  end

  def first
    y = @sensors.size == 14 ? 10 : 2000000
    count_row(y)
  end

  def distress_signal_tuning_frequency
    x, y = find_distress_signal
    4000000 * x + y
  end

end

solve_with(BeaconExclusionZone, EXAMPLE => 26) do |zone|
  zone.scan_interesting_row
end

solve_with(BeaconExclusionZone, EXAMPLE => 56000011) do |zone|
  zone.distress_signal_tuning_frequency
end
