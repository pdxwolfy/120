# Pete Hanson

require 'minitest/autorun'

require_relative 'card'
require_relative 'capture'
require_relative 'participant'
require_relative 'play'

#------------------------------------------------------------------------------

class TestPlayerNew < Minitest::Test
  include Hand

  def setup
    @player = Player.new
    @player.define_singleton_method(:cards_in_hand) { @cards_in_hand }
  end

  def test_new
    assert_equal [], @player.cards_in_hand
  end
end

#------------------------------------------------------------------------------

class TestDealerNew < Minitest::Test
  include Hand

  def setup
    @dealer = Dealer.new
    @dealer.define_singleton_method(:cards_in_hand) { @cards_in_hand }
  end

  def test_new
    assert_equal [], @dealer.cards_in_hand
  end
end

#------------------------------------------------------------------------------

class TestParticipantWins < Minitest::Test
  include Hand

  def setup
    @player = Player.new
  end

  def test_wins
    assert_equal 0, @player.wins
    @player.wins += 1
    assert_equal 1, @player.wins
    @player.wins += 1
    assert_equal 2, @player.wins
  end
end

#------------------------------------------------------------------------------

class TestPlayerBustedMessage < Minitest::Test
  def setup
    @player = Player.new
  end

  def test_result
    assert_equal 'You busted. The dealer wins.', @player.busted_message
  end
end

#------------------------------------------------------------------------------

class TestDealerBustedMessage < Minitest::Test
  def setup
    @dealer = Dealer.new
  end

  def test_result
    assert_equal 'The dealer busted. You win.', @dealer.busted_message
  end
end

#------------------------------------------------------------------------------

class TestPlayerTurn < Minitest::Test
  include Hand
  include Play

  PROMPT = "Hit, Stay, or Quit (H, S, Q)?\n>"
  ERROR = "Invalid input. Please choose H, S, or Q.\n>"

  def setup
    @player = Player.new
  end

  def test_with_eof
    eof, output, result = capture_inout { @player.turn }
    assert eof
    assert_equal PROMPT, output, output.inspect
    assert_nil result
  end

  def test_with_q
    eof, output, result = capture_inout('q') { @player.turn }
    assert eof
    assert_equal "#{PROMPT}", output, output.inspect
    assert_nil result
  end

  def test_with_hit
    eof, output, result = capture_inout('h') { @player.turn }
    refute eof
    assert_equal "#{PROMPT}\n", output, output.inspect
    assert_equal Play::HIT, result
  end

  def test_with_stay
    eof, output, result = capture_inout('s') { @player.turn }
    refute eof
    assert_equal "#{PROMPT}\n", output, output.inspect
    assert_equal Play::STAY, result
  end

  def test_with_error_hit
    eof, output, result = capture_inout('x', 'h') { @player.turn }
    refute eof
    assert_equal "#{PROMPT}\n#{ERROR}\n", output, output.inspect
    assert_equal Play::HIT, result
  end

  def test_with_error_error_stay
    eof, output, result = capture_inout('1', '', 's') { @player.turn }
    refute eof
    assert_equal "#{PROMPT}\n#{ERROR}\n#{ERROR}\n", output, output.inspect
    assert_equal Play::STAY, result
  end

  def test_with_error_error_error_eof
    eof, output, result = capture_inout('1', '', '') { @player.turn }
    assert eof
    assert_equal "#{PROMPT}\n#{ERROR}\n#{ERROR}\n#{ERROR}", output,
                 output.inspect
    assert_nil result
  end
end

#------------------------------------------------------------------------------

class TestDealerTurn < Minitest::Test
  include Hand
  include Play

  def setup
    @dealer = Dealer.new
  end

  def test_already_21
    %w(J A).each { |rank| @dealer.hit(Card.new(rank)) }
    assert_equal Play::STAY, @dealer.turn
  end

  def test_already_17
    %w(J 7).each { |rank| @dealer.hit(Card.new(rank)) }
    assert_equal Play::STAY, @dealer.turn
  end

  def test_already_16
    %w(J 6).each { |rank| @dealer.hit(Card.new(rank)) }
    assert @dealer.turn
    assert_equal Play::HIT, @dealer.turn
  end
end

#------------------------------------------------------------------------------

class TestPlayerShowHand < Minitest::Test
  def setup
    @player = Player.new
  end

  def test_empty_hand
    output = capture_stdout { @player.show_hand }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards:
      This hand is worth 0 points.

    END
  end

  def test_hand_with_1_cards
    %w(A).each { |rank| @player.hit(Card.new(rank)) }
    output = capture_stdout { @player.show_hand }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards: Ace ?
      This hand is worth 11 points.

    END
  end

  def test_hand_with_4_cards
    %w(2 A J 5).each { |rank| @player.hit(Card.new(rank)) }
    output = capture_stdout { @player.show_hand }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards: 2 Ace Jack 5
      This hand is worth 18 points.

    END
  end

  def test_hand_with_10_cards
    %w(2 A 2 A 3 A 4 A 4 2).each { |rank| @player.hit(Card.new(rank)) }
    output = capture_stdout { @player.show_hand }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards: 2 Ace 2 Ace 3 Ace 4 Ace 4 2
      This hand is worth 21 points.

    END
  end
end

#------------------------------------------------------------------------------

class TestDealerShowHand < Minitest::Test
  def setup
    @dealer = Dealer.new
  end

  def test_empty_hand
    output = capture_stdout { @dealer.show_hand }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards:
      This hand is worth 0 points.

    END
  end

  def test_hand_with_1_card
    %w(A).each { |rank| @dealer.hit(Card.new(rank)) }
    output = capture_stdout { @dealer.show_hand }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards: Ace ?
      This hand is worth 11 points.

    END
  end

  def test_hand_with_4_cards
    %w(2 A J 5).each { |rank| @dealer.hit(Card.new(rank)) }
    output = capture_stdout { @dealer.show_hand }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards: 2 Ace Jack 5
      This hand is worth 18 points.

    END
  end

  def test_hand_with_10_cards
    %w(2 A 2 A 3 A 4 A 4 2).each { |rank| @dealer.hit(Card.new(rank)) }
    output = capture_stdout { @dealer.show_hand }
    assert_equal <<~END, output, output.inspect
      The dealer's hand contains these cards: 2 Ace 2 Ace 3 Ace 4 Ace 4 2
      This hand is worth 21 points.

    END
  end
end
