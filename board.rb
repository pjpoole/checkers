class Board
  # "white" moves from 0 toward size - 1 (sense +1)
  # "black" moves from size - 1 toward 0 (sense -1)
  # more of this logic is contained in pieces.rb
  def initialize(size = 8, clean_board = false)
    @size = size

    unless clean_board == true do
      # Populate board with pieces
      # Note: player's rightmost square is light
      # => only dark squares are occupied
      # => Thus: x_x_x_x_ would be a back row
    end

  end

end
