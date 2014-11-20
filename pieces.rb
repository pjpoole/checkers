class Piece
  # "white" moves from 0 toward (size - 1) (sense +1)
  # "black" moves from (size - 1) toward 0 (sense -1)
  COLORS = { w: 1, b: -1 }

  # This is a constant because we'll be manipulating it a couple places.
  # Only works for American and International Checkers, probably.
  DIFFS = [[1,1],[-1,1]]

  attr_reader :pos, :color

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @promoted = false

    @move_diffs = DIFFS.map { |x, y| [x, y * COLORS[@color]] }
    @jump_diffs = DIFFS.map { |x, y| [x * 2, y * 2 * COLORS[@color]] }

    @board[pos] = self
  end

  def to_s
    return (@color == :w ? "O" : "X")
  end

  def inspect
    @pos
  end

  def perform_slide(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    @board[@pos], @board[end_pos] = nil, self

    @pos = end_pos
  end

  def perform_jump(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    @board[@pos], @board[end_pos] = nil, self
    @board[position_sum(@pos, diff.map { |coord| coord / 2 } )] = nil

    @pos = end_pos
  end

  private
  def position_sum(pos, diff)
    pos.zip(diff).map { |coord1, coord2| coord1 + coord2 }
  end

  def move_diffs
    moves = []

    @move_diffs.each_with_index do |diff, i|
      trial_move = position_sum(@pos, diff)

      if @board[trial_move].nil?
        moves << trial_move
        next
      end

      trial_jump = position_sum(@pos, @jump_diffs[i])
      moves << trial_jump if @board[trial_jump].nil? &&
            @board[trial_move].color != @color
    end

    moves
  end

  def maybe_promote
    # don't want the move diffs to grow without bound, so we return
    # early here if we've promoted already.
    return true if @promoted

    # have we reached the end of the board?
    return false unless (@color == :w ? pos[1] == @board.size - 1 : pos[1] == 0)

    # take the diffs, negate them, and add them to the existing diffs.
    # Neat!
    @move_diffs += @move_diffs.map { |x, y| [x, y * -1]}
    @jump_diffs += @jump_diffs.map { |x, y| [x, y * -1]}
  end
end
