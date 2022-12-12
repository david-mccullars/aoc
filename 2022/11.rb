require_relative '../solve'

EXAMPLE = <<-END
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
END

class Monkey

  attr_reader :id, :inspections, :divisor

  def initialize(text, game)
    @game = game
    @inspections = 0
    @pass_rules = {}

    text.lines.each do |line|
      case line
      when /Monkey (\d+):/
        @id = $1.to_i
      when /Starting items: (.*)/
        @items = $1.split(/,\s*/).map_i
      when /Operation: new = (.*)/
        @operation = $1.strip
      when /Test: divisible by (.*)/
        @divisor = $1.to_i
      when /If (true|false): throw to monkey (.*)/
        @pass_rules[$1 == "true"] = $2.to_i
      end
    end
  end

  def inspect_items!
    @inspections += @items.size
    @items.each do |i|
      i = inspect(i)
      @game.pass(i, to: pass_recipient(i))
    end
    @items = []
  end

  def inspect(i)
    # Unprotected eval - what could go wrong?!? SHIPIT!!!
    i = eval @operation.gsub("old", i.to_s)
    i = i / 3 if @game.relief
    i % @game.modulo
  end

  def pass_recipient(i)
    @pass_rules[i % @divisor == 0]
  end

  def receive(i)
    @items << i
  end

end

class MonkeyInTheMiddle

  attr_reader :relief

  def initialize(text)
    @monkeys = text.split("\n\n").map do |section|
      Monkey.new(section, self)
    end.index_by(&:id)
    @relief = true
  end

  def with_no_relief
    @relief = false
    self
  end

  def play(rounds:)
    1.upto(rounds) do
      @monkeys.values.each(&:inspect_items!)
    end
    @monkeys.values.map(&:inspections).max(2).reduce(&:*)
  end

  def pass(item, to:)
    @monkeys.fetch(to).receive(item)
  end

  def modulo
    @modulo ||= @monkeys.values.map(&:divisor).reduce(&:*)
  end

end

solve_with_text(clazz: MonkeyInTheMiddle, EXAMPLE => 10605) do |monkeys|
  monkeys.play(rounds: 20)
end

solve_with_text(clazz: MonkeyInTheMiddle, EXAMPLE => 2713310158) do |monkeys|
  monkeys.with_no_relief.play(rounds: 10_000)
end
