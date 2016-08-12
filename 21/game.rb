# Pete Hanson
# Requires ruby 2.3 or better

require_relative 'busted'
require_relative 'config'
require_relative 'deck'
require_relative 'participant'
require_relative 'play'
require_relative 'screen'
require_relative 'text'

class Game
  def initialize
    @deck = Deck.new with_suits: false
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    show_welcome_message
    loop do
      play_game
      query_play_again
      reset
    end
  ensure
    show_goodbye_message
  end

  private # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def an(card)
    (card.rank == '8' || card.ace?) ? 'an' : 'a'
  end

  def deal_cards
    [@player, @dealer, @player].each { |hand| @deck.deal_to hand }
    @flop = @deck.top_card
  end

  def flop_for_dealer
    @dealer.hit @flop
    puts "The dealer's flop is #{an @flop} #{@flop}."
    @flop = nil
    @dealer.show_hand
  end

  def play_game
    deal_cards
    show_initial_cards
    take_turn_player
    take_turn_dealer
    show_result
  rescue Busted => exception
    show_busted exception
  ensure
    record_winner
    show_wins_and_losses
  end

  def query_play_again
    prompt = 'Press [Return] or [Enter] to play again. Type Q to quit.'
    error = "Invalid response. #{prompt}"
    Input.get(prompt, error) { |input| input.empty? }
    Screen.clear
  end

  def record_winner
    case
    when @player.busted? then @dealer.wins += 1
    when @dealer.busted? then @player.wins += 1
    else
      case @player.points <=> @dealer.points
      when -1 then @dealer.wins += 1
      when +1 then @player.wins += 1
      end
    end
  end

  def reset
    @deck.reset
    @player.reset
    @dealer.reset
  end

  def show_busted(exception)
    puts exception.message
  end

  def show_goodbye_message
    puts 'Thanks for playing 21! Goodbye.'
  end

  def show_initial_cards
    [@player, @dealer].each(&:show_hand)
  end

  def show_result
    case @player.points <=> @dealer.points
    when -1
      puts "The dealer won #{@dealer.points} to #{@player.points}."
    when +1
      puts "You won #{@player.points} to #{@dealer.points}."
    else
      puts "The game ended in a tie with #{@player.points} points each."
    end

    puts ''
  end

  def show_wins_and_losses
    case @player.wins <=> @dealer.wins
    when -1
      puts "The dealer is leading #{@dealer.wins} wins to #{@player.wins}."
    when +1
      puts "You are leading #{@player.wins} wins to #{@dealer.wins}."
    else
      puts "We are tied with #{@player.wins} wins each."
    end
  end

  def show_welcome_message # rubocop:disable MethodLength
    puts Text.word_wrap(<<~END)
      Welcome to 21, the OOP Version!

      The object of 21 is to accumulate cards worth as close to
      #{Config::MAX_POINTS} points as possible without going over (busting).
      The 2-10 cards are worth 2-10 points, respectively; Jacks, Queens and
      Kings are worth 10 points each; Acees can be valued at either 11 points
      or 1 point, depending on which is most convenient at any point in time.

      Both the player and the dealer are dealt 2 cards each from a standard 52
      card deck (one of the dealer's cards is placed face down). The player
      goes first and can either Hit (take another card), or Stay (stop taking
      cards). Then the dealer goes. The deal must Hit if he has fewer than
      #{Config::MUST_STAY} points. If the dealer has #{Config::MUST_STAY}
      points or more, he must Stay.

      If the player busts (goes over #{Config::MAX_POINTS} points), the dealer
      wins. If the player does not bust, but the dealer does, then the player
      wins. Otherwise, the winner is the player with the most points in his
      hand at the end.

    END

    prompt = 'Press [Enter] or [Return] to begin a game. Type Q to quit.'
    Input.get(prompt, prompt) { |input| input.empty? }
    Screen.clear
  end

  def take_turn(who)
    while who.turn == Play::HIT
      card = @deck.deal_to who
      if who == @dealer
        puts "The dealer has been dealt #{an card} #{card}."
      else
        puts "You have been dealt #{an card} #{card}."
      end
      who.show_hand
    end
  end

  def take_turn_dealer
    flop_for_dealer
    take_turn @dealer
  end

  def take_turn_player
    take_turn @player
  end
end
