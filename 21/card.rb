# Pete Hanson

class Card
  attr_reader :suit, :rank

  RANK_INFO = {
    'J' => { name: 'Jack',  type: :face },
    'Q' => { name: 'Queen', type: :face },
    'K' => { name: 'King',  type: :face },
    'A' => { name: 'Ace',   type: :ace  }
  }

  def initialize(rank, suit = nil)
    @rank = rank
    @suit = suit # nil for games that don't need suits
  end

  def ace?
    type == :ace
  end

  def face_card?
    type == :face
  end

  def to_s
    suit ? "#{name} of #{suit.to_s.capitalize}" : name
  end

  def ==(other) # Used primarily for testing purposes
    rank == other.rank && suit == other.suit
  end

  private # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def fetch_rank_info
    RANK_INFO.fetch rank, { name: rank.to_s, type: :number }
  end

  def name
    fetch_rank_info[:name]
  end

  def type
    fetch_rank_info[:type]
  end
end
