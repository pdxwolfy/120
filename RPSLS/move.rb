require_relative 'misc'

class Move
  include Comparable

  attr_reader :value

  WINS = {
    rock:     { scissors: 'crushes',   lizard:   'crushes'     },
    paper:    { rock:     'covers',    spock:    'disproves'   },
    scissors: { paper:    'cuts',      lizard:   'decapitates' },
    lizard:   { spock:    'poisons',   paper:    'eats'        },
    spock:    { rock:     'vaporizes', scissors: 'smashes'     }
  }

  ABBREVS = { p: :paper, r: :rock, sc: :scissors, sp: :spock, l: :lizard }

  def self.allowed_moves
    WINS.keys.map { |move| Move.new(move) }
  end

  def self.choices
    Misc.join_or(WINS.keys)
  end

  def self.game_name
    WINS.keys.map { |value| value.capitalize }.join ', '
  end

  def self.prompt_for_move
    <<~END
      Please choose #{Move.choices} to play.
      Type Q to quit:
    END
  end

  def self.random_move
    Move.new(WINS.keys.sample)
  end

  def self.solicit_move
    Misc.prompt_and_read(Move.prompt_for_move) do |input|
      begin
        exit if input.start_with?('q', 'Q')
        Move.new(input.downcase.to_sym)
      rescue RuntimeError => msg
        puts msg
      end
    end
  end

  def action(loser)
    "#{self} #{WINS[value][loser.value]} #{loser}."
  end

  def to_s
    value.to_s.capitalize
  end

  def <=>(other)
    return 1 unless value
    return 0 if value == other.value
    WINS[value].keys.include?(other.value) ? 1 : -1
  end

private

  def initialize(move)
    @value = ABBREVS.fetch(move, move)
    raise "Invalid move: #{move}" unless WINS.key?(value)
  end
end
