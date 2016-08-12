# Pete Hanson

require 'minitest/autorun'

require_relative 'capture'
require_relative 'game'

module XTestGame
  def self.make_game
    game = Game.new
    game.define_singleton_method(:deck) { @deck }
    game.define_singleton_method(:player) { @player }
    game.define_singleton_method(:dealer) { @dealer }
    game
  end
end

#------------------------------------------------------------------------------

class TestGameNew < Minitest::Test
  def setup
    @game = XTestGame.make_game
  end

  def test_new
    assert_kind_of Deck, @game.deck
    assert_kind_of Player, @game.player
    assert_kind_of Dealer, @game.dealer
  end
end

#------------------------------------------------------------------------------

class TestGameDealCards < Minitest::Test
  def setup
    @game = XTestGame.make_game
    @game.define_singleton_method(:player) { @player }
    @game.define_singleton_method(:dealer) { @dealer }
    @game.__send__(:deal_cards)

    [@game.player, @game.dealer].each do |who|
      who.define_singleton_method(:cards_in_hand) { @cards_in_hand }
    end
  end

  def test_count
    assert_equal 2, @game.player.cards_in_hand.size
    assert_equal 1, @game.dealer.cards_in_hand.size
  end
end

#------------------------------------------------------------------------------

class TestGameShowInitialCards < Minitest::Test
  def setup
    @game = XTestGame.make_game
    @game.define_singleton_method(:player) { @player }
    @game.define_singleton_method(:dealer) { @dealer }
    @game.__send__(:deal_cards)

    [@game.player, @game.dealer].each do |who|
      who.define_singleton_method(:cards_in_hand) { @cards_in_hand }
    end
  end

  def test_show_cards
    player_cards = @game.player.cards_in_hand
    dealer_cards = @game.dealer.cards_in_hand + ['?']
    output = capture_stdout { @game.__send__(:show_initial_cards) }
    assert_equal <<~END, output, output.inspect
      Your hand contains these cards: #{player_cards.join ' '}
      This hand is worth #{@game.player.points} points.

      The dealer's hand contains these cards: #{dealer_cards.join ' '}
      This hand is worth #{@game.dealer.points} points.

    END
  end
end
