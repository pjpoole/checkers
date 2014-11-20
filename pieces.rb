require_relative 'checkers_errors.rb'

class Piece

  # "white" moves from 0 toward (size - 1) (sense +1)
  # "black" moves from (size - 1) toward 0 (sense -1)
  COLORS = { w: 1, b: -1 }

  attr_reader :pos, :color

  def initialize(board, pos, color)
    @board, @pos, @color = board, pos, color
    @promoted = false

    # Only works for American and International Checkers, probably.
    diffs = [[-1,1],[1,1]]
    # So. The way this is going, we want the left move to be on the left,
    # and the right move to be on the right. So we'll reverse the moves if
    # our color is black, so that from the player's point of view left is
    # always on the left.
    diffs.reverse! if color == :b

    @slide_diffs = diffs.map { |x, y| [x, y * COLORS[@color]] }
    @jump_diffs  = diffs.map { |x, y| [x * 2, y * 2 * COLORS[@color]] }

    @board[pos] = self
  end

  # Inspection
  def to_s
    @color == :w ? "O" : "X"
  end

  def inspect
    @pos
  end


  # Moving
  def perform_moves!(move_sequence)

  end

  # TODO: Just implement four-way movement for pieces
  # F*ck moving by co-ords
  def perform_slide(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    @board[@pos], @board[end_pos] = nil, self

    @pos = end_pos
  end

  def perform_jump(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    jumped_pos = position_sum(@pos, diff.map { |coord| coord / 2 })

    @board[@pos], @board[end_pos] = nil, self
    @board[jumped_pos] = nil

    @pos = end_pos
  end

  private
  def position_sum(pos, diff)
    pos.zip(diff).map { |coord1, coord2| coord1 + coord2 }
  end

  def move_diffs
    moves = []

    @slide_diffs.each_with_index do |diff, i|
      trial_move = position_sum(@pos, diff)
      next if trial_move.any? { |x| !x.between?(0, @board.size - 1 ) }

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
    @slide_diffs += @slide_diffs.map { |x, y| [x, y * -1]}
    @jump_diffs  += @jump_diffs.map  { |x, y| [x, y * -1]}
  end
end
