Array.module_eval do

  ORTHOGONAL_DIRECTIONS = {
    r: [0, 1],
    l: [0, -1],
    u: [-1, 0],
    d: [1, 0],
  }.freeze

  def orthogonally_adjacent(direction = ORTHOGONAL_DIRECTIONS.keys)
    case self
    in [Integer, Integer]
      if direction.is_a?(Array)
        direction.map do |dir|
          dy, dx = orthogonal_direction(dir)
          [self[0] + dy, self[1] + dx]
        end
      else
        dy, dx = orthogonal_direction(direction)
        [self[0] + dy, self[1] + dx]
      end
    else
      abort "Can not only call orthogonally_adjacent on array with two integers"
    end
  end

  protected

  def orthogonal_direction(dir)
    case dir
    when *ORTHOGONAL_DIRECTIONS.keys
      d = dir
    else
      d = dir.to_s.downcase[0].to_sym
    end
    ORTHOGONAL_DIRECTIONS[d] or abort "Invalid orthogonal direction: #{dir.inspect}"
  end

end
