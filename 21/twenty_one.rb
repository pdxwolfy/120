#!/usr/bin/env ruby

# Twenty-One is a card game consisting of a dealer and a player, where the
# participants try to get as close to 21 as possible without going over.
#
# Here is an overview of the game:
# - Both participants are initially dealt 2 cards from a 52-card deck.
# - The player takes the first turn, and can "hit" or "stay".
# - If the player busts, he loses. If he stays, it's the dealer's turn.
#    - going over 21 points total is a "bust"
# - The dealer must hit until his cards add up to at least 17.
#     - the dealer must stay once he has 17 points or more
# - If the dealer busts, the player wins. If both player and dealer stays, then
#   the highest total wins.

# Nouns: card, deck, player, dealer, participant, total
# Verbs: deal, hit, stay, bust, win, lose, tie

# Player
#   - hit
#   - stay
#   - busted?
#   - total
#   - win?
#   - lose?
#   - tie?
# Dealer
#   - hit
#   - stay
#   - busted?
#   - total
#   - deal (should this be here, or in Deck?)
#   - win?
#   - lose?
#   - tie?
# Participant > (Player, Dealer)
# Card
# Deck << Cards
#   - deal (should this be here, or in Dealer?)
# Game
#   - start

require_relative 'game'

game = Game.new
game.start
