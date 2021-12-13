require_relative '../solve'

EXAMPLE = <<-END
light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.
END

EXAMPLE2 = <<-END
shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.
END

class BagRules

  RULE_RE = /^([a-z]+ [a-z]+) bags contain (.*)\.$/
  INSIDE_RE = /(\d+) ([a-z]+ [a-z]+) bags?/

  def initialize(lines)
    @rules = {}
    lines.each do |line|
      raise "Invalid #{line}" unless line =~ RULE_RE
      outside, inside = $1, $2
      @rules[outside] = inside.scan(INSIDE_RE).map do |qty, color|
        [color, qty.to_i]
      end.to_h
    end
  end

  def containers(color, used = Set.new)
    @rules.each do |outside, inside|
      next unless inside[color]
      used << outside
      containers(outside, used)
    end
    used.size
  end

  def contents(color)
    @rules[color].sum do |c, qty|
      qty * contents(c)
    end + 1
  end

end

solve_with(BagRules, EXAMPLE => 4) do |rules|
  rules.containers('shiny gold')
end

solve_with(BagRules, EXAMPLE => 32, EXAMPLE2 => 126) do |rules|
  rules.contents('shiny gold') - 1
end
