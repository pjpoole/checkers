require_relative 'board.rb'

class Game

  def initialize
    @game = Board.new
  end

  def play
    turn = 0

    while true
      system "clear"

      puts @game.render

      color = turn % 2 == 0 ? :w : :b
      puts "Player #{turn % 2 + 1}'s turn"
      print "Select piece by coordinates: "
      coords = gets.split(",").map(&:to_i).map { |x| x - 1 }
      puts "Enter move(s) for piece."
      moves = gets.split(",").map do |letter|
        letter.strip.downcase.to_sym
      end
      # Rescue InputError


      @game[coords].perform_moves(moves)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  game = Game.new
  game.play
end
