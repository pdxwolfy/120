# Pete Hanson

require_relative 'config'
require_relative 'hand'
require_relative 'input'
require_relative 'play'

#------------------------------------------------------------------------------
# The Participant base class probably is not needed for this assignment.
# However, I suspect the Bonus Features for this assignmen may make this
# necessary. So, I'm leaving it in place for now.

class Participant
  include Hand

  attr_accessor :wins

  def initialize
    reset_hand
    self.wins = 0
  end

  def reset
    reset_hand
  end
end

#------------------------------------------------------------------------------

class Player < Participant
  def busted_message
    'You busted. The dealer wins.'
  end

  def show_hand
    display_hand 'Your'
  end

  def turn
    prompt = 'Hit, Stay, or Quit (H, S, Q)?'
    error = 'Invalid input. Please choose H, S, or Q.'
    choice = Input.get_downcase prompt, error do |input|
      %w(h s).include? input
    end
    choice == 'h' ? Play::HIT : Play::STAY
  end
end

#------------------------------------------------------------------------------

class Dealer < Participant
  def busted_message
    'The dealer busted. You win.'
  end

  def show_hand
    display_hand "The dealer's"
  end

  def turn
    points < Config::MUST_STAY ? Play::HIT : Play::STAY
  end
end
