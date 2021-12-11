require 'bundler'
Bundler.require

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

def input(day, suffix)
  AoC.handle_name(AoC.get_year, "DAY#{day}_#{suffix}") or abort "Invalid suffix #{suffix.inspect}"
end

def solve(suffix = :lines, **examples)
  @letter = @letter ? (@letter.ord + 1).chr : 'A'
  puts "========================== #{@letter} =========================="

  prev_caller = caller.reject { |line| line.start_with?(__FILE__) }[0]
  abort "Can not determine day: #{prev_caller}" unless /\A(\d+)[a-z]?\.rb/ =~ prev_caller
  day = $1.to_i

  examples.each do |input, expected_result|
    actual_result = yield example(input, suffix)
    if expected_result != actual_result
      abort "Expected result (#{expected_result}) does not equal actual result (#{actual_result.inspect})"
    end
  end

  result = yield input(day, suffix)
  puts "RESULT: #{result}", nil
end

%i[lines text numbers number].each do |suffix|
  define_method("solve_with_#{suffix}") do |*args, **opts, &block|
    solve(suffix, *args, **opts, &block)
  end
end

def solve_with_commands(allowed_commands, *args, **opts)
  solve(*args, **opts) do |lines|
    commands = lines.map do |line|
      if line =~ /^(#{allowed_commands.join('|')}) (\d+)$/
        [$1, $2.to_i]
      else
        raise "Invalid: #{line.inspect}"
      end
    end
    yield commands
  end
end

def solve_with_line_of_numbers(*args, **opts, &block)
  solve(:text, *args, **opts) do |text|
    yield text.split(/\s*,\s*/).map(&:to_i)
  end
end

def solve_with(clazz, *args, **opts)
  solve(*args, **opts) do |lines|
    yield lines.map { |line| clazz.new(line) }
  end
end
