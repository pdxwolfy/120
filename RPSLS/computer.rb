require_relative 'misc'
require_relative 'move'
require_relative 'player'

class Computer < Player
  WHICH_OPPONENT = 'Which opponent do you want to play?'

  def self.register(the_module, name)
    @personalities[name] = the_module
  end

  def self.solicit_name
    available_names = @personalities.keys.sort
    choice = Misc.select_from_list(WHICH_OPPONENT, available_names) do |input|
      exit if input.start_with?('q', 'Q')
    end
    available_names[choice]
  end

private

  @personalities = {}

  def self.personality(name)
    @personalities[name]
  end

  def initialize(name)
    super(name)
    extend(Computer.personality(name))
  end
end

#------------------------------------------------------------------------------
# Always plays :spock

module Robby
  def choose
    self.move = Move.new(:spock)
  end

  def hint
    'Robby always plays Spock.'
  end
end

Computer.register(Robby, 'Robby')

#------------------------------------------------------------------------------
# Uses random selection of moves

module Rosie
  def choose
    self.move = Move.random_move
  end

  def hint
    'Rosie makes plays at random.'
  end
end

Computer.register(Rosie, 'Rosie')

#------------------------------------------------------------------------------
# Uses moves in sequence

module TNGData # "Data" conflicts with built-in class
  def choose
    @moves ||= Move.allowed_moves
    @moves.rotate!
    self.move = @moves.last
  end

  def hint
    "Data plays #{Move.game_name} and then repeats."
  end
end

Computer.register(TNGData, 'Data')

#------------------------------------------------------------------------------
# Uses moves in reversed sequence

module Lore
  def choose
    @moves ||= Move.allowed_moves.reverse
    @moves.rotate!
    self.move = @moves.last
  end

  def hint
    reverse_moves = Move.game_name.split(', ').reverse.join(', ')
    "Lore plays #{reverse_moves} and then repeats."
  end
end

Computer.register(Lore, 'Lore')

#------------------------------------------------------------------------------
# First play is at random. Each subsequent play is the play made by the human
# player on the previous game.

module WallE
  def choose
    human, _, _ = HistoryList.instance.previous_game
    self.move = human ? human.move : Move.random_move
  end

  def hint
    <<~'END'
      Wall-E's first move is always random. On each subsequent play, he plays
      what you played on your previous game.
    END
    # (fix for syntax coloring in Atom)'
  end
end

Computer.register(WallE, 'Wall-E')

#------------------------------------------------------------------------------
# First play is at random. Each subsequent play is the winning play from the
# previous game.

module SevenOfNine
  def choose
    _, _, winner = HistoryList.instance.previous_game
    self.move = winner ? winner.move : Move.random_move
  end

  def hint
    <<~'END'
      7-of-9's first move is always random. On each subsequent play, she plays
      the winning move from the previous game.
    END
    # (fix for syntax coloring in Atom)'
  end
end

Computer.register(SevenOfNine, '7-of-9')
