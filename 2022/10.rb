require_relative '../solve'

EXAMPLE = <<-END
addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
END

class CathodeRayTube

  include Display

  def initialize(operations)
    @operations = operations
    @signals = process
  end

  def process(x = 1)
    @operations.each_with_object([x]) do |line, signals|
      if line =~ /addx (.+)/
        signals << x
        x += $1.to_i
      end
      signals << x
    end.tap(&:pop)
  end

  def signal_strengths
    ((20...@signals.size) % 40).sum do |cycle|
      cycle * @signals[cycle-1]
    end
  end

  def display
    @display ||= @signals.each_slice(40).map do |signals|
      signals.map.with_index do |x, i|
        (x - i).abs <= 1 ? ON : OFF
      end.join
    end.join("\n")
  end

end

solve_with(CathodeRayTube, EXAMPLE => 13140) do |crt|
  crt.signal_strengths
end

solve_with(CathodeRayTube) do |crt|
  puts crt.fancy_display
  crt.parsed_display
end
