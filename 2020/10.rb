require_relative '../solve'

EXAMPLE_1 = <<-END
16
10
15
5
1
11
7
19
6
12
4
END

EXAMPLE_2 = <<-END
28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3
END

class AdapterChain

  def initialize(adapters)
    @adapters = [0, *adapters.sort, adapters.max + 3]
  end

  def jolt_differences
    @jolt_differences ||= @adapters.each_cons(2).map { |a, b| b - a }
  end

  def arrangements
    return 0 if jolt_differences.any? { |delta| delta > 3 }

    jolt_differences.slice_after(3).map do |group|
      Math.variable_m_bonacci(*recursion_quantities(group))
    end.reduce(:*)
  end

  # Map a group of jolt differences (e.g. 1 1 1 2 2)
  # to the same number of recursion quantities, i.e. how many
  # "steps backwards" can we take at each difference and still
  # have no more than 3 total delta
  def recursion_quantities(group)
    sum = 0
    i0 = -1
    group.size.times.map do |i1|
      sum += group[i1]
      while sum > 3
        i0 += 1
        sum -= group[i0]
      end
      i1 - i0
    end
  end

end

solve_with_numbers(clazz: AdapterChain, EXAMPLE_1 => 7 * 5, EXAMPLE_2 => 22 * 10) do |chain|
  chain.jolt_differences.tally.values_at(1, 3).reduce(:*)
end

solve_with_numbers(clazz: AdapterChain, EXAMPLE_1 => 8, EXAMPLE_2 => 19208) do |chain|
  chain.arrangements
end
