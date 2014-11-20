class Piece

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color

    @promoted = false
  end

  def perform_slide
  end

  def perform_jump
  end

  def move_diffs
  end

  def maybe_promote
  end
end
