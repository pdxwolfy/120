# Pete Hanson

require 'minitest/autorun'
require 'set'

require_relative 'deck'
require_relative 'participant'

#------------------------------------------------------------------------------

class TestDeckNewWithSuits < Minitest::Test
  def setup
    @deck = Deck.new
    @deck.define_singleton_method(:number_of_cards) { @cards.size }
  end

  def test_52_cards
    assert_equal 52, @deck.number_of_cards
  end
end

#------------------------------------------------------------------------------

class TestDeckNewWithoutSuits < Minitest::Test
  def setup
    @deck = Deck.new(with_suits: false)
    @deck.define_singleton_method(:number_of_cards) { @cards.size }
  end

  def test_52_cards
    assert_equal 52, @deck.number_of_cards
  end
end

#------------------------------------------------------------------------------

class TestDeckDealToWithSuits < Minitest::Test
  include Hand

  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def setup
    @deck = Deck.new
    @expected_cards = {
      clubs:    Set.new(RANKS),
      diamonds: Set.new(RANKS),
      hearts:   Set.new(RANKS),
      spades:   Set.new(RANKS)
    }
  end

  def busted_message
    'dummy message'
  end

  def deal_card
    @deck.deal_to(self)
  rescue Busted
    nil
  end

  def test_all_cards_with_player
    reset_hand
    52.times do
      deal_card
      suit = @cards_in_hand.last.suit.to_sym
      @expected_cards[suit].delete(@cards_in_hand.last.rank)
      @expected_cards.delete(suit) if @expected_cards[suit].empty?
    end
    assert @expected_cards.empty?
  end
end

#------------------------------------------------------------------------------

class TestDeckDealToWithoutSuits < Minitest::Test
  include Hand
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def setup
    @deck = Deck.new
    @expected_cards = RANKS.each_with_object({}) do |rank, hash|
      hash[rank] = 4
    end
  end

  def busted_message
    'dummy message'
  end

  def deal_card
    @deck.deal_to(self)
  rescue Busted
    nil
  end

  def test_all_cards
    reset_hand
    52.times do
      deal_card
      rank = @cards_in_hand.last.rank
      @expected_cards[rank] -= 1
      @expected_cards.delete(rank) if @expected_cards[rank] == 0
    end
    assert @expected_cards.empty?
  end
end

#------------------------------------------------------------------------------

class TestDeckResetWithSuits < Minitest::Test
  include Hand

  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def setup
    @deck = Deck.new
    @deck.define_singleton_method(:number_of_cards) { @cards.size }
    @expected_cards = {
      clubs:    Set.new(RANKS),
      diamonds: Set.new(RANKS),
      hearts:   Set.new(RANKS),
      spades:   Set.new(RANKS)
    }
  end

  def busted_message
    'dummy message'
  end

  def deal_card
    @deck.deal_to(self)
  rescue Busted
    nil
  end

  def test_deck_size
    reset_hand
    assert_equal 52, @deck.number_of_cards
    deal_card
    deal_card
    assert_equal 50, @deck.number_of_cards
    @deck.reset
    assert_equal 52, @deck.number_of_cards
    deal_card
    assert_equal 51, @deck.number_of_cards
  end

  def test_has_suit
    reset_hand
    deal_card
    assert @cards_in_hand.last.suit
    @deck.reset
    deal_card
    assert @cards_in_hand.last.suit
  end
end

#------------------------------------------------------------------------------

class TestDeckResetWithoutSuits < Minitest::Test
  include Hand

  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)

  def setup
    @deck = Deck.new with_suits: false
    @deck.define_singleton_method(:number_of_cards) { @cards.size }
  end

  def busted_message
    'dummy message'
  end

  def deal_card
    @deck.deal_to(self)
  rescue Busted
    nil
  end

  def test_deck_size
    reset_hand
    assert_equal 52, @deck.number_of_cards
    deal_card
    deal_card
    assert_equal 50, @deck.number_of_cards
    @deck.reset
    assert_equal 52, @deck.number_of_cards
    deal_card
    assert_equal 51, @deck.number_of_cards
  end

  def test_has_suit
    reset_hand
    deal_card
    refute @cards_in_hand.last.suit
    @deck.reset
    deal_card
    refute @cards_in_hand.last.suit
  end
end
