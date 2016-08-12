# Pete Hanson

require 'minitest/autorun'

require_relative 'capture'
require_relative 'card'
require_relative 'hand'

#------------------------------------------------------------------------------

class TestHandClearHand < Minitest::Test
  include Hand

  def test_clear
    reset_hand
    assert_equal [], @cards_in_hand
    assert_equal 0, @points_in_hand
  end

  def test_clear_with_cards_in_hand
    reset_hand
    hit(Card.new('4'))
    hit(Card.new('A'))
    reset_hand
    assert_equal [], @cards_in_hand
    assert_equal 0, @points_in_hand
  end
end

#------------------------------------------------------------------------------

class TestHandHit < Minitest::Test
  include Hand

  def busted_message
    'This is a dummy busted message'
  end

  def test_add_1
    reset_hand
    assert_equal Card.new('4'), hit(Card.new('4'))
    assert_equal 1, @cards_in_hand.size
    assert_equal '4', @cards_in_hand[0].to_s
  end

  def test_add_2
    reset_hand
    assert_equal Card.new('4'), hit(Card.new('4'))
    assert_equal Card.new('10'), hit(Card.new('10'))
    assert_equal 2, @cards_in_hand.size
    assert_equal '4', @cards_in_hand[0].to_s
    assert_equal '10', @cards_in_hand[1].to_s
  end

  def test_add_3
    reset_hand
    assert_equal Card.new('4'), hit(Card.new('4'))
    assert_equal Card.new('J'), hit(Card.new('J'))
    assert_equal Card.new('7'), hit(Card.new('7'))
    assert_equal 3, @cards_in_hand.size
    assert_equal '4', @cards_in_hand[0].to_s
    assert_equal 'Jack', @cards_in_hand[1].to_s
    assert_equal '7', @cards_in_hand[2].to_s
  end

  def test_add_busted_as_player
    reset_hand
    assert_equal Card.new('5'), hit(Card.new('5'))
    assert_equal Card.new('J'), hit(Card.new('J'))
    begin
      hit(Card.new('7'))
      refute true, 'You should have busted, but did not'
    rescue Busted => exception
      assert_equal busted_message, exception.message
    end
  end
end

#------------------------------------------------------------------------------

class TestHandPoints < Minitest::Test
  include Hand

  def setup
    reset_hand
  end

  def test_no_aces_to_21
    hit(Card.new('4'))
    assert_equal 4, points

    hit(Card.new('J'))
    assert_equal 14, points

    hit(Card.new('7'))
    assert_equal 21, points
  end

  def test_with_ace
    hit(Card.new('A'))
    assert_equal 11, points

    hit(Card.new('J'))
    assert_equal 21, points
  end

  def test_with_busted_but_ace
    hit(Card.new('A'))
    assert_equal 11, points

    hit(Card.new('7'))
    assert_equal 18, points

    hit(Card.new('5'))
    assert_equal 13, points
  end

  def test_with_multiple_aces
    4.times do |n|
      hit(Card.new('A'))
      assert_equal n + 11, points
    end

    hit(Card.new('2'))
    assert_equal 16, points

    hit(Card.new('6'))
    assert_equal 12, points
  end
end

#------------------------------------------------------------------------------

class TestHandBustedQ < Minitest::Test
  include Hand

  def setup
    reset_hand
  end

  def busted_message
    'This is a dummy busted message'
  end

  def test_no_aces_to_23
    %w(4 J 7).each { |rank| hit(Card.new(rank)) }
    begin
      hit(Card.new('2'))
      refute true, 'You should have busted, but did not'
    rescue Busted => exception
      assert_equal busted_message, exception.message
    end
  end

  def test_no_aces_to_22
    %w(3 J 7).each { |rank| hit(Card.new(rank)) }
    begin
      hit(Card.new('2'))
      refute true, 'You should have busted, but did not'
    rescue Busted => exception
      assert_equal busted_message, exception.message
    end
  end

  def test_with_aces_to_23
    %w(A J 2).each { |rank| hit(Card.new(rank)) }
    begin
      hit(Card.new('10'))
      refute true, 'You should have busted, but did not'
    rescue Busted => exception
      assert_equal busted_message, exception.message
    end
  end

  def test_with_aces_to_22
    %w(9 A 2).each { |rank| hit(Card.new(rank)) }
    begin
      hit(Card.new('10'))
      refute true, 'You should have busted, but did not'
    rescue Busted => exception
      assert_equal busted_message, exception.message
    end
  end
end

#------------------------------------------------------------------------------

class TestHandDisplayHand < Minitest::Test
  include Hand

  def setup
    reset_hand
  end

  def test_empty_hand
    output = capture_stdout { display_hand('Your') }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards:
      This hand is worth 0 points.

    END
  end

  def test_hand_with_1_cards
    %w(A).each { |rank| hit(Card.new(rank)) }
    output = capture_stdout { display_hand("The dealer's") }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards: Ace ?
      This hand is worth 11 points.

    END
  end

  def test_hand_with_4_cards
    %w(2 A J 5).each { |rank| hit(Card.new(rank)) }
    output = capture_stdout { display_hand('Your') }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards: 2 Ace Jack 5
      This hand is worth 18 points.

    END
  end

  def test_hand_with_10_cards
    %w(2 A 2 A 3 A 4 A 4 2).each { |rank| hit(Card.new(rank)) }
    output = capture_stdout { display_hand("The dealer's") }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards: 2 Ace 2 Ace 3 Ace 4 Ace 4 2
      This hand is worth 21 points.

    END
  end
end
