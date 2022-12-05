require_relative '../solve'

EXAMPLE = <<-END
1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc
END

class PasswordPolicy

  def initialize(line)
    line =~ /^(\d+)-(\d+) ([a-z]): ([a-z]+)$/ or raise "Invalid input: #{line}"
    @v1, @v2 = [$1, $2].map(&:to_i)
    @char, @password = [$3, $4]
  end

  def minmax_valid?
    Range.new(@v1, @v2).include?(@password.scan(/#{@char}/).size)
  end

  def position_valid?
    [@v1 - 1, @v2 - 1].map { |v| @password[v] == @char }.reduce(&:^)
  end

end

solve_with_each(PasswordPolicy, EXAMPLE => 2) do |policies|
  policies.count(&:minmax_valid?)
end

solve_with_each(PasswordPolicy, EXAMPLE => 1) do |policies|
  policies.count(&:position_valid?)
end
