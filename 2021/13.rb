require_relative '../solve'

EXAMPLE = <<-END
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
END

class FoldedInstructions

  def initialize(text)
    dot_input, fold_input = text.split(/\n\n/, 2)

    @dots = dot_input.lines.map do |line|
      line.split(',', 2).map(&:to_i)
    end

    @folds = fold_input.lines.map do |fold|
      [$1.to_sym, $2.to_i] if fold.chomp =~ /^fold along (x|y)=(\d+)$/
    end
  end

  def fold_all
    fold until @folds.empty?
  end

  def fold
    axis, value = @folds.shift
    @dots.each do |dot|
      i = axis == :x ? 0 : 1
      dot[i] = 2 * value - dot[i] if dot[i] > value
    end
    @dots.uniq!
  end

  def visible_dots
    @dots.size
  end

  def to_s
    output = Array.new(output_height) { ' ' * output_width }
    @dots.each do |x, y|
      output[y][x] = "█"
    end
    output.join("\n")
  end

  def output_width
    @dots.map(&:first).max + 1
  end

  def output_height
    @dots.map(&:last).max + 1
  end

end

solve_with(FoldedInstructions, :text, EXAMPLE => 17) do |instructions|
  instructions.fold
  instructions.visible_dots
end

solve_with(FoldedInstructions, :text) do |instructions|
  instructions.fold_all
  puts "\e[31m#{instructions}\e[0m"
  warn "No automated solution.  Above must be typed in manually"
  exit 0
end
