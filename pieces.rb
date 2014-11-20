class Piece
  COLORS = { w: 1, b: -1 }
  # Okay, so, apparently ruby slicers don't work like python slicers.
  # This is a constant because we'll be manipulating it a couple places.
  # Only works for American and International Checkers, probably.
  DIFFS = [[1,1],[-1,1]]

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color

    @promoted = false

    move_diffs = DIFFS.map { |x, y| [x, y * COLORS[@color]] }
    jump_diffs = DIFFS.map { |x, y| [x * 2, y * 2 * COLORS[@color]] }
    @diffs = move_diffs + jump_diffs
    @board[pos] = self
  end

  def to_s
    return (@color == :w ? "O " : "X ")
  end

  def perform_slide(diff)
    return false unless move_diffs.include?(diff)

    @pos = position_sum(@pos, diff)

  end

  def perform_jump(diff)
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
