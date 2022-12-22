require_relative '../solve'
require 'tsort'

EXAMPLE = <<-END
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
END

class Hash

  include TSort
  alias tsort_each_node each_key

  def tsort_each_child(node)
    m1, _, m2 = fetch(node)
    if m1 && m2
      yield m1
      yield m2
    end
  end

end

class MonkeyMath

  def initialize(lines)
    @jobs = {}

    lines.each do |line|
      case line
      when /^(....): (\d+)$/    
        @jobs[$1] = $2.to_i
      when /^(....): (....) (.) (....)$/
        @jobs[$1] = [$2, $3, $4]
      end
    end
  end

  def root
    @root ||= yells.fetch("root")
  end

  def yells
    @jobs.tsort.each_with_object({}) do |monkey, h|
      m1, op, m2 = @jobs.fetch(monkey)
      if m1 && m2
        y1, y2 = h.values_at(m1, m2)
        if y1.is_a?(Integer) && y2.is_a?(Integer)
          h[monkey] = y1.send(op, y2)
        else
          h[monkey] = [y1, op, y2]
        end
      else
        h[monkey] = m1
      end
    end
  end

  def handle_mistranslation
    @jobs['humn'] = :human
    solve(root[0], root[2])
  end

  def solve(left, right)
    loop do
      left, right = simplify(left, right)
      return right if left == :human
    end
  end

  def simplify(left, right)
    (a, op, b) = left
    aint = a.is_a?(Integer)
    case op
    when '+'
      aint ? [b, right - a] : [a, right - b]
    when '-'
      aint ? [b, a - right] : [a, b + right]
    when '*'
      aint ? [b, right / a] : [a, right / b]
    when '/'
      aint ? [b, a / right] : [a, b * right]
    end
  end

end

solve_with(MonkeyMath, EXAMPLE => 152) do |math|
  math.root
end

solve_with(MonkeyMath, EXAMPLE => 301) do |math|
  math.handle_mistranslation
end
