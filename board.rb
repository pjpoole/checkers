require_relative 'pieces.rb'

class Board
  # "white" moves from 0 toward size - 1 (sense +1)
  # "black" moves from size - 1 toward 0 (sense -1)
  # more of this logic is contained in pieces.rb
  COLORS = { w: 1, b: -1 }

  attr_reader :size

  def initialize(size = 8, clean_board = false)
    @size = size # should be even!
    @board = Array.new(@size) { Array.new(@size) }

    # Note: player's rightmost square is light
    # => only dark squares are occupied
    # => Thus: x_x_x_x_ would be a back row
    COLORS.each_key { |color| populate(color) } unless clean_board == true

  end

  def [](pos)
    x, y = pos
    @board[y][x]
  end

  def []=(pos, piece)
    x, y = pos
    @board[y][x] = piece
  end

  def render
    rendering = ""
    @board.each_with_index do |col, y|
      col_flipped = col.reverse
      y_flipped = @size - y
      rendering << "#{y_flipped}"

      col_flipped.each_with_index do |el, x| # is a piece or an empty cell
        rendering << (el.nil? ? "  " : (@board[y_flipped - 1][x]).to_s)
      end

      rendering << "\n"
    end

    rendering += " 1 2 3 4 5 6 7 8 \n"
  end

  private
  def populate(color)
    start = (color == :w ? 0 : @size - 1)
    sense = COLORS[color]

    3.times do |dy|
      (@size / 2).times do |dx|
        y = start + (dy * sense)
        x = y % 2 + dx * 2
        Piece.new(self, [x,y], color)
      end
    end

  end

end # end of class Board

if $PROGRAM_NAME == __FILE__
  board = Board.new
  puts board.render
end
