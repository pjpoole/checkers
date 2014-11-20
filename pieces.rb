require_relative 'checkers_errors.rb'

class Piece

  # "white" moves from 0 toward (size - 1) (sense +1)
  # "black" moves from (size - 1) toward 0 (sense -1)
  COLORS = { w: 1, b: -1 }
  MOVES = { l: 0, r: 1, bl: 2, br: 3 }

  attr_reader :pos, :color

  def initialize(board, pos, color, promoted = false)
    @board, @pos, @color, @promoted = board, pos, color, promoted

    # This only works for normal variants of checkers.
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

  # standard functions
  def to_s
    @color == :w ? "O" : "X"
  end

  def inspect
    @pos
  end

  def dup(board)
    Piece.new(board, @pos.dup, @color, @promoted)
  end

  # Moving
  # TODO: Just implement four-way movement for pieces (l, r, bl, br)
  # F*ck moving by co-ords or diffs.
  def perform_moves(sym_move_sequence)
    orig_move_sequence = to_diffs(sym_move_sequence)
    move_sequence = orig_move_sequence.dup

    if valid_move_seq?(move_sequence)
      perform_moves!(orig_move_sequence)
    else
      raise InvalidMoveError
    end
  end

  protected
  attr_accessor :promoted

  # Moving
  def perform_moves!(move_sequence)
    case move_sequence.count
    when 0
      raise InputError.new('No input provided')
    when 1
      next_move = move_sequence.shift

      if @slide_diffs.include?(next_move)
        raise InvalidMoveError unless perform_slide(next_move)
        maybe_promote
      elsif @jump_diffs.include?(next_move)
        raise InvalidMoveError unless perform_jump(next_move)
        maybe_promote
      else
        raise InvalidMoveError
      end

    else
      begin
        raise InvalidMoveError if perform_jump(move_sequence.shift)
        maybe_promote
      end until move_sequence.empty?
    end
  end

  private
  def valid_move_seq?(move_sequence)
    board_dup = @board.dup

    begin
      board_dup[@pos].perform_moves!(move_sequence)
    rescue InvalidMoveError
      return false
    end

    true
  end

  def perform_slide(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    @board[@pos], @board[end_pos] = nil, self

    @pos = end_pos
    puts "end of method"
    true
  end

  def perform_jump(diff)
    end_pos = position_sum(@pos, diff)
    return false unless move_diffs.include?(end_pos)

    jumped_pos = position_sum(@pos, diff.map { |coord| coord / 2 })

    @board[@pos], @board[end_pos] = nil, self
    @board[jumped_pos] = nil

    @pos = end_pos
    true
  end

  def position_sum(pos, diff)
    pos.zip(diff).map { |coord1, coord2| coord1 + coord2 }
  end

  # Helpers
  def to_diffs(sym_move_sequence)
    sym_move_sequence.map { |sym| @slide_diffs[MOVES[sym]] }
  end

  def move_diffs
    moves = []

    @slide_diffs.each_with_index do |diff, i|
      trial_move = position_sum(@pos, diff)
      # Move won't work if it's out of bounds
      next if trial_move.any? { |x| !x.between?(0, @board.size - 1 ) }

      if @board[trial_move].nil? # Empty cell, valid move
        moves << trial_move
        next # ... but obviously we can't jump past an empty cell
      end

      # Check to see if the position two in front of you is empty,
      # and the position before that has an enemy
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
