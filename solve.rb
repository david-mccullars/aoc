require 'bundler'
require 'singleton'
Bundler.require

# Kinda hacky, but we're going to capture the day when first loaded
prev_caller = caller.reject { |line| line.start_with?(__FILE__) }[0]
abort "Can not determine year/day: #{prev_caller}" unless prev_caller =~ %r{(?:(\d{4})/)?(\d+)[a-z]*\.rb:}
year, day = $1, $2
ENV['AOC_YEAR'] = year || Time.new.year.to_s
AoC.define_singleton_method(:day) { day.to_i }

#########################################################################

class SolutionPoster

  include Singleton

  attr_reader :part

  def initialize
    @part = 0
  end

  def agent
    require "mechanize" unless defined?(Mechanize)
    @agent ||= Mechanize.new do |agent|
      cookie = Mechanize::Cookie.new("session", AoC.get_session_cookie)
      cookie.domain = ".adventofcode.com"
      cookie.path = "/"
      agent.cookie_jar.add(cookie)
    end
  end

  def challenge_page
    @challenge_page ||= agent.get("https://adventofcode.com/#{AoC.get_year}/day/#{AoC.day}")
  end

  def challenge_form
    challenge_page.forms.first or raise "No form to post solution for day #{AoC.day}!"
  end

  def solution_posted?
    require "lightly" unless defined?(Lightly)
    Lightly.get("solution_posted_#{AoC.get_year}_#{AoC.day}_#{part}") do
      case part
      when 1
        !challenge_page.css('#part2').empty? || challenge_page.forms.empty?
      when 2
        challenge_page.forms.empty?
      else
        raise "Invalid part: #{part}"
      end
    end
  end

  def post_solution(answer)
    @part = @part + 1
    return if solution_posted?

    challenge_form["answer"] = answer
    case (response = challenge_form.submit).css("article").to_s
    when /That's not the right answer/i
      raise "The answer #{answer} is incorrect"
    when /(You gave an answer too recently[^\[<]*)/
      raise $1
    when /(That's the right answer[^\[<]*)/
      puts $1
    else
      raise response.css('article').to_s
    end
  end

end

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
