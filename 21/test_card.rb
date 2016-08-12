# Pete Hanson

require 'minitest/autorun'

require_relative 'card'

#------------------------------------------------------------------------------

class TestCardNew < Minitest::Test
  def test_2_hearts
    card = Card.new('2', :hearts)
    assert_equal '2', card.rank
    assert_equal :hearts, card.suit
  end

  def test_3_clubs
    card = Card.new('3', :clubs)
    assert_equal '3', card.rank
    assert_equal :clubs, card.suit
  end

  def test_7_no_suit
    card = Card.new('7')
    assert_equal '7', card.rank
    assert_nil card.suit
  end

  def test_8_no_suit
    card = Card.new('8', :spades)
    assert_equal '8', card.rank
    assert_equal :spades, card.suit
  end

  def test_10_diamonds
    card = Card.new('10', :diamonds)
    assert_equal '10', card.rank
    assert_equal :diamonds, card.suit
  end

  def test_jack_clubs
    card = Card.new('J', :clubs)
    assert_equal 'J', card.rank
    assert_equal :clubs, card.suit
  end

  def test_queen_queen_no_suit
    card = Card.new('Q')
    assert_equal 'Q', card.rank
    assert_nil card.suit
  end

  def test_ace_diamonds
    card = Card.new('A', :diamonds)
    assert_equal 'A', card.rank
    assert_equal :diamonds, card.suit
  end
end

#------------------------------------------------------------------------------

class TestCardEquals < Minitest::Test
  def test_rank_and_suit
    @card1 = Card.new('5', :diamonds)
    @card2 = Card.new('6', :diamonds)
    @card3 = Card.new('5', :hearts)
    @card4 = Card.new('6', :diamonds)
    assert @card1 != @card2, "#{@card1}\n#{@card2}"
    assert @card1 != @card3, "#{@card1}\n#{@card3}"
    assert @card1 != @card4, "#{@card1}\n#{@card4}"
    assert @card2 != @card1, "#{@card2}\n#{@card1}"
    assert @card2 != @card3, "#{@card2}\n#{@card3}"
    assert @card2 == @card4, "#{@card2}\n#{@card4}"
    assert @card3 != @card1, "#{@card3}\n#{@card1}"
    assert @card3 != @card2, "#{@card3}\n#{@card2}"
    assert @card3 != @card4, "#{@card3}\n#{@card4}"
    assert @card4 != @card1, "#{@card4}\n#{@card1}"
    assert @card4 == @card2, "#{@card4}\n#{@card2}"
    assert @card4 != @card3, "#{@card4}\n#{@card3}"
  end

  def test_rank_only
    @card1 = Card.new('5')
    @card2 = Card.new('6')
    @card3 = Card.new('5')
    @card4 = Card.new('6')
    assert @card1 != @card2, "#{@card1}\n#{@card2}"
    assert @card1 == @card3, "#{@card1}\n#{@card3}"
    assert @card1 != @card4, "#{@card1}\n#{@card4}"
    assert @card2 != @card1, "#{@card2}\n#{@card1}"
    assert @card2 != @card3, "#{@card2}\n#{@card3}"
    assert @card2 == @card4, "#{@card2}\n#{@card4}"
    assert @card3 == @card1, "#{@card3}\n#{@card1}"
    assert @card3 != @card2, "#{@card3}\n#{@card2}"
    assert @card3 != @card4, "#{@card3}\n#{@card4}"
    assert @card4 != @card1, "#{@card4}\n#{@card1}"
    assert @card4 == @card2, "#{@card4}\n#{@card2}"
    assert @card4 != @card3, "#{@card4}\n#{@card3}"
  end
end

#------------------------------------------------------------------------------

class TestCardAceQ < Minitest::Test
  def test_not_ace_with_suit
    %w(2 3 4 5 6 7 8 9 10 J Q K).each do |rank|
      card = Card.new(rank, %i(hearts clubs diamonds spades).sample)
      refute card.ace?
    end
  end

  def test_not_ace_without_suit
    %w(2 3 4 5 6 7 8 9 10 J Q K).each do |rank|
      card = Card.new(rank)
      refute card.ace?
    end
  end

  def test_ace_with_suit
    %i(hearts clubs diamonds spades).each do |suit|
      card = Card.new('A', suit)
      assert card.ace?
    end
  end

  def test_ace_without_suit
    card = Card.new('A')
    assert card.ace?
  end
end

#------------------------------------------------------------------------------

class TestCardFaceCardQ < Minitest::Test
  def test_not_face_card_with_suit
    %w(2 3 4 5 6 7 8 9 10 A).each do |rank|
      card = Card.new(rank, %i(hearts clubs diamonds spades).sample)
      refute card.face_card?
    end
  end

  def test_not_face_card_without_suit
    %w(2 3 4 5 6 7 8 9 10 A).each do |rank|
      card = Card.new(rank)
      refute card.face_card?
    end
  end

  def test_face_card_with_suit
    %w(J Q K).each do |rank|
      card = Card.new(rank, %i(hearts clubs diamonds spades).sample)
      assert card.face_card?
    end
  end

  def test_face_card_without_suit
    %w(J Q K).each do |rank|
      card = Card.new(rank)
      assert card.face_card?
    end
  end
end

#------------------------------------------------------------------------------

class TestCardToS < Minitest::Test
  def test_2
    card = Card.new('2', :hearts)
    assert_equal '2 of Hearts', card.to_s
  end

  def test_3
    card = Card.new('3', :clubs)
    assert_equal '3 of Clubs', card.to_s
  end

  def test_8
    card = Card.new('8', :spades)
    assert_equal '8 of Spades', card.to_s
  end

  def test_9
    card = Card.new('9')
    assert_equal '9', card.to_s
  end

  def test_10
    card = Card.new('10', :diamonds)
    assert_equal '10 of Diamonds', card.to_s
  end

  def test_jack
    card = Card.new('J', :clubs)
    assert_equal 'Jack of Clubs', card.to_s
  end

  def test_queen
    card = Card.new('Q', :hearts)
    assert_equal 'Queen of Hearts', card.to_s
  end

  def test_king
    card = Card.new('K')
    assert_equal 'King', card.to_s
  end

  def test_ace
    card = Card.new('A')
    assert_equal 'Ace', card.to_s
  end
end
