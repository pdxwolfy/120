require 'singleton'

class HistoryList
  include Singleton

  class Event
    attr_reader :human, :computer, :winner

    def to_s
      result = winner ? "#{winner.name} won" : 'Tie game'
      format('%-20.20s  %-20.20s  %s',
             "#{human.name}: #{human.move}",
             "#{computer.name}: #{computer.move}",
             result)
    end

  private

    def initialize(human, computer, winner)
      @human = human.clone
      @computer = computer.clone
      @winner = winner&.clone
    end
  end

  def all_events
    @history.clone.freeze
  end

  def previous_game
    event = @history.last
    event ? [event.human, event.computer, event.winner] : [nil, nil, nil]
  end

  def record_history(human_player, computer_player, game_winner)
    @history << Event.new(human_player, computer_player, game_winner)
  end

private

  def initialize
    @history = []
  end
end
