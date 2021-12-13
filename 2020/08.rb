require_relative '../solve'

EXAMPLE = <<-END
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
END

class BootCode

  attr_reader :accumulator

  def initialize(lines)
    @instructions = lines.map do |line|
      line =~ /^(nop|acc|jmp) \+?([-]?\d+)$/ or raise "Invalid #{line}"
      [$1.to_sym, $2.to_i]
    end
  end

  def reset
    @line = 0
    @accumulator = 0
  end

  def run
    reset
    lines_run = Set.new
    loop do
      lines_run << @line
      run_next
      return false if lines_run.include?(@line)
      return true if @line == @instructions.size
    end
  end

  def run_next
    cmd, value = @instructions[@line]
    case cmd
    when :nop
      @line += 1
    when :acc
      @accumulator += value
      @line += 1
    when :jmp
      @line = @line + value
    end
  end

  def fixed_run
    @instructions.any? do |i|
      modified_run(i)
    end
  end

  def modified_run(instruction)
    cmd, value = instruction
    return false if cmd == :acc
    instruction[0] = cmd == :nop ? :jmp : :nop
    run
  ensure
    instruction[0] = cmd
  end

  def graph
    @graph ||= {}.tap do |g|
      @instructions.each_with_index do |(cmd, value), i|
        g[i] = i + (cmd == :jmp ? value : 1)
      end
    end
  end

end

solve_with(BootCode, EXAMPLE => 5) do |code|
  code.run
  code.accumulator
end

solve_with(BootCode, EXAMPLE => 8) do |code|
  code.fixed_run
  code.accumulator
end
