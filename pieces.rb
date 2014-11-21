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
    str = @color == :w ? "o" : "x"
    str.upcase if @promoted
    str
  end

  def inspect
    @pos
  end

  def dup(board)
    Piece.new(board, @pos.dup, @color, @promoted)
  end

  def validate_input(player_color)
    raise InputError.new('Piece doesn\'t belong to player') unless
          @board[@pos].color == player_color
    raise InputError.new('Piece is blocked in') unless
          @slide_diffs.map { |diff| position_sum(@pos, diff) }.
          any? { |pos| @board[pos].nil? || @board[pos].color != @color }
    true
  end

  # Moving
  # TODO: Just implement four-way movement for pieces (:l, :r, :bl, :br)
  # F*ck moving by co-ords or diffs.
  def perform_moves(sym_move_sequence)
    move_sequence = to_indices(sym_move_sequence)

    if valid_move_seq?(move_sequence)
      perform_moves!(move_sequence)
    else
      raise InvalidMoveError.new('Move not valid')
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
      idx = move_sequence[0]

      perform_move(@jump_diffs[idx]) unless perform_move(@slide_diffs[idx])
      maybe_promote
    when 2
      begin
        idx = move_sequence.shift
        perform_move(@jump_diffs[idx])
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

  def perform_move(diff)
    end_pos = position_sum(@pos, diff)
    raise InvalidMoveError.new('Destination out of bounds') unless
          end_pos.all? { |coord| coord.between?(0, @board.size - 1) }

    slide = (diff[0]).abs == 1

    near_pos = position_sum(@pos, (diff.map { |x| x / 2 }) ) unless slide

    if slide && @board[end_pos].nil?
      @board[@pos], @board[end_pos] = nil, self
    elsif @board[end_pos].nil? && @board[near_pos].color != @color
      @board[@pos], @board[end_pos] = nil, self
      @board[near_pos] = nil
    else
      return false
    end

    @pos = end_pos

    true
  end

  def position_sum(pos, diff)
    pos.zip(diff).map { |coord1, coord2| coord1 + coord2 }
  end

  # Helpers
  def to_indices(sym_move_sequence)
    sym_move_sequence.map { |sym| MOVES[sym] }
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
    return true if @promoted == true

    # have we reached the end of the board?
    return false unless (@color == :w ? pos[1] == @board.size - 1 : pos[1] == 0)

    # take the diffs, negate them, and add them to the existing diffs.
    # Neat!
    @slide_diffs += @slide_diffs.map { |x, y| [x, y * -1]}
    @jump_diffs  += @jump_diffs.map  { |x, y| [x, y * -1]}

    @promoted = true
  end
end
