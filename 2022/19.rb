require_relative '../solve'
require 'parallel'

EXAMPLE = <<-END
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
END

module Resources

  ORE       = 0
  CLAY      = 1
  OBSIDIAN  = 2
  GEODE     = 3

  def ore;      self[ORE]; end
  def clay;     self[CLAY]; end
  def obsidian; self[OBSIDIAN]; end
  def geode;    self[GEODE]; end

  def Resources.[](ore: 0, clay: 0, obsidian: 0, geode: 0)
    [ore, clay, obsidian, geode]
  end

  def add(other)
    [
      self[ORE] + other[ORE],
      self[CLAY] + other[CLAY],
      self[OBSIDIAN] + other[OBSIDIAN],
      self[GEODE] + other[GEODE],
    ]
  end

  def minus(other)
    [
      self[ORE] - other[ORE],
      self[CLAY] - other[CLAY],
      self[OBSIDIAN] - other[OBSIDIAN],
      self[GEODE] - other[GEODE],
    ]
  end

  def >=(other)
    self[ORE] >= other[ORE] &&
    self[CLAY] >= other[CLAY] &&
    self[OBSIDIAN] >= other[OBSIDIAN] &&
    self[GEODE] >= other[GEODE]
  end

end

ROBOTS = [
  Resources[ore: 1],
  Resources[clay: 1],
  Resources[obsidian: 1],
  Resources[geode: 1],
]

module State

  def minutes;    self[0]; end
  def resources;  self[1]; end
  def production; self[2]; end

  def produce
    [minutes - 1, resources.add(production), production]
  end

  def build(robot_type, cost)
    [minutes, resources.minus(cost), production.add(ROBOTS[robot_type])]
  end

  def max_geode_possible
    resources.geode + production.geode * minutes  + (minutes * (minutes + 1) / 2)
  end

end

Array.send(:include, Resources)
Array.send(:include, State)

class Blueprint

  extend WithMemoizedMethods
  extend HasFormat

  has_format <<~END.strip.gsub(/\s+/, " ")
    Blueprint {{i:id}}:
      Each ore robot costs {{i:ore}} ore.
      Each clay robot costs {{i:clay}} ore.
      Each obsidian robot costs {{i:obsidian1}} ore and {{i:obsidian2}} clay.
      Each geode robot costs {{i:geode1}} ore and {{i:geode2}} obsidian.
  END

  attr_reader :id

  def initialize
    @build_costs = {
      Resources::GEODE =>    Resources[ore: @geode1, obsidian: @geode2],
      Resources::OBSIDIAN => Resources[ore: @obsidian1, clay: @obsidian2],
      Resources::CLAY =>     Resources[ore: @clay],
      Resources::ORE =>      Resources[ore: @ore],
    }

    @max_necessary = [
      @build_costs.values.map(&:ore).max,
      @build_costs.values.map(&:clay).max,
      @build_costs.values.map(&:obsidian).max,
      Float::INFINITY,
    ]
  end

  def max_geode(minutes)
    @max_geode = 0
    start = [minutes, Resources[], ROBOTS[Resources::ORE]]
    check_options(start)
    @max_geode
  end

  def check_options(state)
    @max_geode = state.resources.geode if @max_geode < state.resources.geode

    # Rule: Stop when it's time to stop!
    return if state.minutes <= 0

    # Optimization: If we can't possibly produce enough geode in the time
    # left to beat the maximum already found, then skip it.
    return if state.max_geode_possible < @max_geode

    next_state = state.produce

    @build_costs.each do |robot_type, cost|
      # Rule: Make sure we can afford to build the robot
      next unless state.resources >= cost

      # Optimization: Don't bother building robots if we already produce
      # enough of a given resource to buy whatever we need.
      next if state.production[robot_type] >= @max_necessary[robot_type]

      check_options(next_state.build(robot_type, cost))

      # Optimization: If we have an option to build a high value robot
      # assume that is always the best option and ignore other build
      # options. This WILL fail in some cases (in partciular the example)
      # but seems to works with the real input.
      break if robot_type >= Resources::OBSIDIAN
    end

    # Optimization: If we had enough ore to buy anything we want,
    # then we should have built something - no need to consider a
    # "produce only" option.
    return if state.resources.ore >= @max_necessary[Resources::ORE]

    check_options(next_state)

    nil
  end

  memoize :check_options

end

solve_with_format([Blueprint], EXAMPLE => 33) do |blueprints|
  Parallel.map(blueprints) do |b|
    b.max_geode(24) * b.id
  end.sum
end

solve_with_format([Blueprint]) do |blueprints|
  Parallel.map(blueprints.first(3)) do |b|
    b.max_geode(32)
  end.reduce(:*)
end
