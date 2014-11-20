class Board
  # "white" moves from 0 toward size - 1 (sense +1)
  # "black" moves from size - 1 toward 0 (sense -1)
  # more of this logic is contained in pieces.rb

  attr_reader :size

  def initialize(size = 8, clean_board = false)
    @size = size
    @board = Array.new(@size) { Array.new(@size) }

    unless clean_board == true do
      # Populate board with pieces
      # Note: player's rightmost square is light
      # => only dark squares are occupied
      # => Thus: x_x_x_x_ would be a back row
    end
  end

  def [](pos)
    x, y = pos
    @board[y][x]
  end

  def []=(pos)
    x, y = pos
    @board[y][x] = pos
  end

  def render
    
  end

  private

end
