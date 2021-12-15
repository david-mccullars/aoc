require 'bundler'
require 'singleton'
require 'set'
Bundler.require
Dir['lib/**/*.rb'].sort.each { |f| load(f) }

#########################################################################

# Kinda hacky, but we're going to capture the day when first loaded
prev_caller = caller.reject { |line| line.start_with?(__FILE__) }[0]
abort "Can not determine year/day: #{prev_caller}" unless prev_caller =~ %r{(?:(\d{4})/)?(\d+)[a-z]*\.rb:}
year, day = $1, $2
ENV['AOC_YEAR'] = year || Time.new.year.to_s
AoC.define_singleton_method(:day) { day.to_i }

#########################################################################

def example(data, suffix)
  case suffix
  when :lines
    data.lines(chomp: true)
  when :text
    data.chomp
  when :numbers
    data.lines.map(&:to_i)
  when :number
    data.lines.first.to_i
  else
    abort "Invalid example suffix: #{suffix.inspect}"
  end
end

def input(suffix)
  AoC.handle_name(AoC.get_year, "DAY#{AoC.day}_#{suffix}") or abort "Invalid suffix #{suffix.inspect}"
end

def classify(data, clazz)
  clazz ? clazz.new(data) : data
end

def solve(suffix = :lines, clazz: nil, **examples)
  @letter = @letter ? (@letter.ord + 1).chr : 'A'
  puts "========================== #{@letter} =========================="

  examples.each do |input, expected_result|
    actual_result = yield classify(example(input, suffix), clazz)
    if expected_result != actual_result
      abort "Expected result (#{expected_result}) does not equal actual result (#{actual_result.inspect})"
    end
  end

  result = yield classify(input(suffix), clazz)
  puts "RESULT: #{result}", nil
  SolutionPoster.instance.post_solution(result)
end

%i[lines text numbers number].each do |suffix|
  define_method("solve_with_#{suffix}") do |**opts, &block|
    solve(suffix, **opts, &block)
  end
end

def solve_with_line_of_numbers(clazz: nil, **opts)
  solve(:text, **opts) do |text|
    yield classify(text.split(/\s*,\s*/).map(&:to_i), clazz)
  end
end

def solve_with_grouped_lines(clazz: nil, **opts)
  solve(:text, **opts) do |text|
    yield classify(text.split(/\n\n/).map { |g| g.lines.map(&:chomp) }, clazz)
  end
end

def solve_with_grid_of_numbers(clazz: nil, **opts)
  solve(**opts) do |lines|
    grid = {}
    lines.each_with_index do |line, row|
      line.chars.each_with_index do |c, col|
        grid[[row, col]] = c.to_i
      end
    end
    yield classify(grid, clazz)
  end
end

def solve_with(clazz, *args, **opts)
  solve(*args, **opts) do |data|
    yield classify(data, clazz)
  end
end

def solve_with_each(clazz, *args, **opts)
  solve(*args, **opts) do |data|
    yield data.map { |d| classify(d, clazz) }
  end
end
