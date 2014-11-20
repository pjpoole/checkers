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
    @board[y][x] = pos
  end

  def render
    rendering = ""
    @board.each_with_index do |row, i|

      rendering << "#{i + 1}"
      row.each do |el| # is a piece or an empty cell
        rendering << (el.nil? ? "  " : "0 ")
      end
      rendering << "\n"
    end

    rendering += " 1 2 3 4 5 6 7 8 \n"
  end

  private
  def populate(color)
    start = (color == :w ? 0 : @size - 1)
    sense = (color == :w ? 1 : -1)

    3.times do |dy|
      (@size / 2).times do |dx|
        y, x = [start + (dy * sense), (dy % 2 + dx * 2) * sense]
        Piece.new(self, [x,y], color)
      end
    end

  end

end # end of class Board

if $PROGRAM_NAME == __FILE__
  board = Board.new
  puts board.render
end
