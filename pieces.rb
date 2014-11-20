class Piece
  COLOR = { w: 1, b: -1 }
  # Okay, so, apparently ruby slicers don't work like python slicers.
  # => White can *jump* using DIFFS[0..1]
  # => White can *move* using DIFFS[2..3]
  # => Black can *move* using DIFFS[4..5]
  # => Black can *jump* using DIFFS[6..7]
  # => @promoted pieces can move/jump using DIFFS
  # Thus:
  # => Iterating over DIFFS[]
  DIFFS = [
    [ 2, 2],
    [-2, 2],
    [ 1, 1],
    [-1, 1],
    [ 1,-1],
    [-1,-1],
    [ 2,-2],
    [-2,-2],
  ]

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color

    @promoted = false
  end

  def perform_slide(diff)
    return false unless move_diffs.include?(diff)

    @pos = position_sum(@pos, diff
    
  end

  def perform_jump
    return false unless move_diffs.include?(diff)

    @pos = position_sum(@pos, diff)
    @board
  end

  def move_diffs

  end

  def position_sum(pos, diff)
    pos.zip(diff).map { |coord1, coord2| coord1 + coord2 }
  end

  def maybe_promote
    @color == :w ? pos[1] == @board.size - 1 : pos[1] == 0
  end
end
