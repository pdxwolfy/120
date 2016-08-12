# Pete Hanson

require_relative 'card'

class Deck
  SUITS = %i(hearts diamonds clubs spades)
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def initialize(with_suits: true)
    @with_suits = with_suits
    reset
  end

  def deal_to(hand)
    hand.hit @cards.pop
  end

  def reset
    @cards = SUITS.product(RANKS).shuffle.map do |suit, rank|
      Card.new(rank, @with_suits ? suit : nil)
    end
  end

  def top_card
    # ASSUMPTION: we will create a new deck with each game, so there should
    # always be enough cards.
    @cards.pop
  end
end
