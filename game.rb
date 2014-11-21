require_relative 'board.rb'

class Game

  def initialize
    @game = Board.new
    @size = @game.size
  end

  def play
    turn = 0

    until @game.game_over?
      system "clear"

      puts @game.render

      color = turn % 2 == 0 ? :w : :b
      puts "Player #{turn % 2 + 1}'s turn"

      coords = get_piece(color)
      play_moves(coords)

      turn += 1
    end
  end

  private
  def get_piece(color)
    begin
      print "Select piece by coordinates: "
      coords = gets.split(",").map(&:to_i).map { |x| x - 1 }.take(2)
      validate_input(coords, color)
    rescue InputError => e
      puts "Invalid input: #{e.message}"
      retry
    end

    coords
  end

  def play_moves(coords)
    begin
      puts "Enter move(s) for piece."
      moves = gets.split(",").map do |letter|
        letter.strip.downcase.to_sym
      end

      @game[coords].perform_moves(moves)
    rescue InvalidMoveError => e
      puts "Invalid move sequence: #{e.message}"
      retry
    end

    moves
  end

  def validate_input(coords, color)
    raise InputError.new('Out of bounds') unless
          coords.all? { |x| x.between?(0, @size - 1) }
    raise InputError.new('No piece at location') unless
          !@game[coords].nil?
    @game[coords].validate_input(color)
  end

end

if $PROGRAM_NAME == __FILE__
  game = Game.new
  game.play
end
