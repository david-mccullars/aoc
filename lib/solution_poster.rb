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
    when /(That's the right answer!)/
      puts $1
    else
      raise response.css('article').to_s
    end
  end

end
