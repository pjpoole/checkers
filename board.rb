require_relative 'pieces.rb'
require_relative 'checkers_errors.rb'


class Board

  COLORS = { w: 1, b: -1 }

  attr_accessor :board
  attr_reader :size

  def initialize(size = 8, clean_board = false)
    # size should be even! There are no rulesets for odd-sized checkers boards.
    # Behavior with an odd-sized board is undefined.
    @size = size
    @board = Array.new(@size) { Array.new(@size) }

    # Note: player's rightmost square is light
    # => only dark squares are occupied
    # => Thus: x_x_x_x_ would be a back row
    COLORS.each_key { |color| populate(color) } unless clean_board == true
  end

  def dup
    board_dup = Board.new(@size, true)

    @board.each_with_index do |row, x|
      row.each_with_index do |el, y|
        board_dup[[y,x]] = el.dup(board_dup) unless el.nil?
      end
    end

    board_dup
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

    (@board.count - 1).downto(0) do |x|
      rendering << (x + 1).to_s

      @size.times do |y|
        el = @board[x][y]
        rendering << (el.nil? ? "  " : el.to_s.concat(" "))
      end

      rendering << "\n"
    end

    rendering += " 1 2 3 4 5 6 7 8 \n"
  end

  def count_pieces # debug method
    puts @board.flatten.compact.tap { |x| x.each { |el| p el } }.count
  end

  private
  def populate(color)
    start = (color == :w ? 0 : @size - 1)
    sense = COLORS[color]

    # Populate all but the center two rows.
    # Typical of most checkers variants.
    (size / 2 - 1).times do |dy|
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
