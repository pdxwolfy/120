require 'pry'

class Player
  attr_reader :move, :name

  def winner(other)
    if move > other.move
      self
    elsif move < other.move
      other
    end
  end

protected

  attr_writer :move

private

  def initialize
    @name = solicit_name
  end
end

#------------------------------------------------------------------------------

class Computer < Player
  def choose
    self.move = Move.new(%i(rock paper scissors).sample)
  end

private

  def initialize
    super
  end

  def solicit_name
    %w(Robby C3P0 Hal).sample
  end
end

#------------------------------------------------------------------------------

class Human < Player
  def choose
    loop do
      puts 'Please choose rock, paper, or scissors:'
      begin
        self.move = Move.new(gets.chomp.downcase.to_sym)
        break
      rescue RuntimeError
        puts 'Sorry, invalid choice.'
      end
    end
  end

private

  def initialize
    super
  end

  def solicit_name
    loop do
      puts 'What is your name?'
      name = gets
      break name.chomp unless name.nil? || name.empty?
      print 'Your name is required.'
    end
  end
end

#------------------------------------------------------------------------------

class Move
  VALUES = %i(rock paper scissors)
  WINS = { rock: :scissors, scissors: :paper, paper: :rock }

  def to_s
    value.to_s
  end

  def >(other)
    WINS[value] == other.value
  end

  def <(other)
    other > self
  end

protected

  attr_accessor :value

private

  def initialize(value)
    fail "Invalid move: #{value}" unless VALUES.include?(value)
    self.value = value
  end
end

#------------------------------------------------------------------------------

class RPSGame
  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end

private

  attr_accessor :human, :computer

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye, #{human.name}!"
  end

  def display_welcome_message
    puts "Hi #{human.name}. Welcome to Rock, Paper, Scissors!"
  end

  def display_winner
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
    puts case human.winner(computer)
         when human    then "#{human.name} won! Congratulations."
         when computer then "#{computer.name} won! Sorry."
         else               'Tie!'
         end
  end

  def initialize
    self.human = Human.new
    self.computer = Computer.new
  end

  def play_again?
    loop do
      puts 'Do you want to play again? (y/n)'
      answer = gets.chomp.downcase
      break answer == 'y' if answer.start_with?('y', 'n')
    end
  end
end

RPSGame.new.play
