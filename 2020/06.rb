require_relative '../solve'

EXAMPLE = <<-END
abc

a
b
c

ab
ac

a
a
a
a

b
END

def process_forms(groups, &op)
  groups.sum do |lines|
    lines.map { |line| line.chars.uniq }.reduce(&op).size
  end
end

solve_with_grouped_lines(EXAMPLE => 11) do |groups|
  process_forms(groups, &:|)
end

solve_with_grouped_lines(EXAMPLE => 6) do |groups|
  process_forms(groups, &:&)
end
