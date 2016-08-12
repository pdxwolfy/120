#!/usr/bin/env ruby

require_relative 'computer'
require_relative 'history_list'
require_relative 'human'
require_relative 'move'

class RPSLSGame
  MATCH_SCORE = 5

  def play
    display_welcome_message
    begin
      play_game_and_show_results until match_over?
    rescue SystemExit
      nil
    end

    display_leader_and_score('', 'won the match')
    display_history
    display_goodbye_message
  end

private

  def chose(player)
    "#{player.name} chose #{player.move}."
  end

  def display_game_results
    puts chose(@human_player), chose(@computer_player)

    winner = game_winner
    if winner
      loser = other_player(winner)
      puts winner.move.action(loser.move), "#{winner.name} won!"
    else
      puts 'Tie!'
    end

    puts
  end

  def display_goodbye_message
    puts <<~END

      Thanks for playing #{Move.game_name}.
      Good bye, #{@human_player.name}!

    END
  end

  def display_history
    puts '', '   Play history for this match', '   ---------------------------'
    @history.all_events.each { |event| puts "   #{event}" }
    puts
  end

  def display_leader_and_score(prefix, suffix)
    leader = match_leader
    print leader ? "#{prefix}#{leader.name} #{suffix} " : 'The match is tied '
    if @human_wins > @computer_wins
      puts "#{@human_wins}-#{@computer_wins}."
    else
      puts "#{@computer_wins}-#{@human_wins}."
    end
  end

  def display_welcome_message
    puts <<~END

      Hi #{@human_player.name}. Welcome to #{Move.game_name}.
      Your opponent is #{@computer_player.name}.
      #{@computer_player.hint}

      The first player to win #{MATCH_SCORE} games wins the match.
      You may quit at any time by typing Q.

    END
  end

  def game_winner
    return @computer_player if @human_player.move < @computer_player.move
    return @human_player    if @human_player.move > @computer_player.move
  end

  def initialize(human_name, computer_name)
    @history         = HistoryList.instance
    @human_player    = Human.new(human_name)
    @computer_player = Computer.new(computer_name)
    @human_wins      = 0
    @computer_wins   = 0
  end

  def match_leader
    case @human_wins <=> @computer_wins
    when -1 then @computer_player
    when  1 then @human_player
    end
  end

  def match_over?
    [@human_wins, @computer_wins].max >= MATCH_SCORE
  end

  def other_player(player)
    player == @human_player ? @computer_player : @human_player
  end

  def play_game_and_show_results
    @human_player.choose
    @computer_player.choose
    record_winner

    system 'clear'
    display_game_results
    @history.record_history(@human_player, @computer_player, game_winner)
    display_leader_and_score('Current score: ', 'leads the match')
  end

  def record_winner
    case game_winner
    when @human_player    then @human_wins += 1
    when @computer_player then @computer_wins += 1
    end
  end
end

human_name = Human.solicit_name
computer_name = Computer.solicit_name
RPSLSGame.new(human_name, computer_name).play
