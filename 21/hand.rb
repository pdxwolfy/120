# Pete Hanson

require_relative 'busted'
require_relative 'config'

module Hand
  def busted?
    @points_in_hand > Config::MAX_POINTS
  end

  def display_hand(whose)
    @show = @cards_in_hand.clone
    @show << '?' if @show.size == 1

    puts <<~END
      #{whose} hand contains these cards: #{@show.join ' '}
      This hand is worth #{@points_in_hand} points.

    END
  end

  def hit(card)
    @cards_in_hand << card
    calculate_points
    raise(Busted, busted_message) if busted?
    card
  end

  def points
    @points_in_hand
  end

  def reset_hand
    @cards_in_hand = []
    @points_in_hand = 0
  end

  private # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def calculate_points
    @points_in_hand += points_for @cards_in_hand.last
    recalculate_points if busted?
  end

  def recalculate_points
    @points_in_hand = @cards_in_hand.reduce(0) do |accum, card|
      accum + points_for(card)
    end

    @cards_in_hand.select(&:ace?).each { @points_in_hand -= 10 if busted? }
  end

  def points_for(card)
    case
    when card.ace?       then 11
    when card.face_card? then 10
    else                      card.rank.to_i
    end
  end
end
