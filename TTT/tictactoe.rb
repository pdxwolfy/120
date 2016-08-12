#!/usr/bin/env ruby

module Text
  def self.join_or(list, sep = ', ', final = 'or')
    if list.size <= 1 || final.empty?
      list.join(sep) # e.g., "3"
    elsif list.size == 2
      list.join(" #{final} ") # e.g., "3 or 5"
    else
      # e.g., "3, 4, or 6"
      list.take(list.size - 1).join(sep) + "#{sep}#{final} #{list.last}"
    end
  end

  # Yes, I understand this. I can even write this from scratch, but I didn't.
  # I figured it was okay to steal it since it isn't a critical element of this
  # program.
  def self.word_wrap(text, width = 78)
    text.gsub(/\n/, ' ').gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end
end

module Screen
  def self.clear
    system 'clear'
  end
end

#------------------------------------------------------------------------------

class Player
  attr_accessor :marker, :wins, :name

  def initialize(marker, name)
    @marker = marker
    @name = name
    @wins = 0
  end

  def to_s
    name
  end

  def ==(other)
    marker == other.marker && name == other.name
  end

  def ===(other)
    self == other
  end
end

#------------------------------------------------------------------------------

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def ==(other)
    marker == other.marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

#------------------------------------------------------------------------------

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def count_markers(keys)
    squares_to_check = @squares.values_at(*keys)
    squares_to_check.each_with_object(Hash.new(0)) do |square, counts|
      counts[square.marker] += 1
    end
  end

  ROWS = { 1 => [1, 2, 3], 5 => [4, 5, 6], 9 => [7, 8, 9] }
  def display
    (3 * 3 + 2).times do |row|
      if row.even?
        puts '     |     |'
      elsif row % 4 == 3
        puts '-----+-----+-----'
      else
        puts squares_at(*ROWS[row]).map { |square| "  #{square}  " }.join('|')
      end
    end
  end

  def full?
    unmarked_keys_at.empty?
  end

  def game_over?
    full? || someone_won?
  end

  # Returns all potential winning lines for "marker" that have exactly "number"
  # squares with that marker already set.
  def in_a_row(number, marker)
    WINNING_LINES.select do |line|
      counts = count_markers(line)
      counts[marker] == number && counts[Square::INITIAL_MARKER] == (3 - number)
    end
  end

  def someone_won?
    !(!winning_marker)
  end

  def squares_at(*keys)
    @squares.values_at(*keys)
  end

  def unmarked_keys_at(keys = (1..9).to_a)
    keys.select { |key| @squares[key].unmarked? }
  end

  def winning_marker
    WINNING_LINES.each do |line|
      count_markers(line).each_pair do |marker, count|
        return marker if count == 3 && marker != Square::INITIAL_MARKER
      end
    end
    nil
  end
end

#------------------------------------------------------------------------------

module ComputerMoveChooser
  def computer_choose_move
    offensive_move || defensive_move || center_move || random_move
  end

  private #--------------------------------------------------------------------

  def best_move_for(marker)
    check_lines = board.in_a_row(2, marker)
    return if check_lines.empty?

    pick_line = check_lines.sample
    board.unmarked_keys_at(pick_line).sample
  end

  def center_move
    5 if board.squares_at(5).first.unmarked?
  end

  def defensive_move
    best_move_for(human.marker)
  end

  def offensive_move
    best_move_for(computer.marker)
  end

  def random_move
    board.unmarked_keys_at.sample
  end
end

#------------------------------------------------------------------------------

module HumanMoveChooser
  def human_choose_move
    choices = board.unmarked_keys_at.map(&:to_s)
    prompt = 'Choose one of the following squares or commands: ' +
             Text.join_or(choices + %w(Q H))
    error = "Sorry, that's not a valid choice."

    wrapped_prompt = Text.word_wrap(prompt)
    move = Match.get_validated_input(wrapped_prompt, error) do |input|
      choices.include?(input)
    end
    move.to_i
  end
end

#------------------------------------------------------------------------------

class Game
  include ComputerMoveChooser
  include HumanMoveChooser

  attr_reader :board, :human, :computer

  def initialize(human, computer, first_player)
    @board = Board.new
    @human = human
    @computer = computer
    @first_player = first_player # set nil after first player announcement
    @current_player = first_player
  end

  def play
    loop do
      display_board
      current_player_moves
      break if board.game_over?
      Screen.clear
    end
    display_result
  end

  def winning_player
    case board.winning_marker
    when human.marker    then human
    when computer.marker then computer
    end
  end

  private #--------------------------------------------------------------------

  def current_player_moves
    if @current_player == human
      @board[human_choose_move] = @current_player.marker
      @current_player = computer
    else
      @board[computer_choose_move] = @current_player.marker
      @current_player = human
    end
  end

  def display_goes_first
    if @first_player == human
      puts "You go first, #{human}."
    else
      puts "#{computer} has gone first."
    end

    puts
  end

  def display_board
    puts "Your marker is an #{human.marker}, #{human}.",
         "#{computer}'s marker is an #{computer.marker}",
         ''

    if @first_player && @current_player == human
      display_goes_first
      @first_player = nil
    end

    board.display
    puts
  end

  def display_result
    Screen.clear
    display_board
    case board.winning_marker
    when human.marker    then puts "You won, #{human}!"
    when computer.marker then puts "#{computer} won!  Too bad, measly human."
    else                      puts "It's a tie!"
    end

    puts
  end
end

#------------------------------------------P------------------------------------

class Match
  GAME_NAME = 'Tic Tac Toe'
  MARKER_X = 'X'
  MARKER_O = 'O'
  WINNING_SCORE_FOR_MATCH = 5
  # FIRST_PLAYER = :computer
  # FIRST_PLAYER = :human
  FIRST_PLAYER = :choose

  def self.display_help
    puts '', Text.word_wrap(<<~END)
      #{GAME_NAME} is played on a board of 3x3 squares. The goal is to place 3
      of your markers in a row in any direction. A match continues until one of
      the players has won #{WINNING_SCORE_FOR_MATCH} games, or until you quit.
    END

    puts '', Text.word_wrap(<<~END), ''
      You may type Q or q to quit at any time. You may also type H or h to
      display this help.
    END
  end

  def self.display_goodbye_message
    puts "Thanks for playing #{GAME_NAME}}! Goodbye!"
  end

  def self.display_welcome_message
    Screen.clear
    puts "Welcome to #{GAME_NAME}!", ''
    display_help
  end

  def self.handle_common_commands(command)
    case command
    when 'q', 'Q' then exit
    when 'h', 'H' then Match.display_help
    else               return false
    end

    true
  end

  def self.get_validated_input(prompt, error)
    the_prompt = prompt
    loop do
      input = prompted_input_with_common_commands(the_prompt) || next
      return input unless block_given? && !yield(input)
      the_prompt = error
    end
  end

  def play
    Match.display_welcome_message
    setup_players
    begin
      play_match
    rescue SystemExit
      display_match_results
    ensure
      Match.display_goodbye_message
    end
  end

  private #--------------------------------------------------------------------

  def self.prompted_input_with_common_commands(prompt)
    puts prompt
    print '> '
    input = gets || exit
    puts
    input.chomp!
    return input unless Match.handle_common_commands(input)
  end

  def determine_first_player
    @first_player =
      case FIRST_PLAYER
      when :computer then @computer
      when :human    then @human
      when :choose   then solicit_first_player
      end

    puts 'Who goes first in each game will alternate.', ''
  end

  def display_match_results # rubocop:disable MethodLength
    if @human.nil?
      puts 'The match was never begun.'
    elsif @human.wins >= WINNING_SCORE_FOR_MATCH
      puts "#{@human}, you won the match #{@human.wins} to #{@computer.wins}!"
    elsif @computer.wins >= WINNING_SCORE_FOR_MATCH
      puts "#{@computer} won the match #{@computer.wins} to #{@human.wins}!"
    else
      puts 'The match was not completed.'
      puts "Final score: #{@human} #{@human.wins} - " \
           "#{@computer} #{@computer.wins}"
    end
  end

  def display_match_status
    if @human.wins > @computer.wins
      puts "#{@human}, you lead the match #{@human.wins} to #{@computer.wins}."
    elsif @human.wins < @computer.wins
      puts "#{@computer} leads the match #{@computer.wins} to #{@human.wins}."
    else
      puts "The match is tied at #{@human.wins} each."
    end
    puts
  end

  def match_over?
    [@human.wins, @computer.wins].max >= WINNING_SCORE_FOR_MATCH
  end

  def play_1_game
    @game = Game.new(@human, @computer, @first_player)
    @game.play
    update_score @game.winning_player
    return nil if match_over?

    display_match_status
    solicit_continuation
    @first_player = (@first_player == @human) ? @computer : @human
  end

  def play_match
    solicit_continuation('begin')
    while play_1_game; end
    display_match_results
  end

  def setup_players
    name = solicit_human_name
    human_marker = solicit_human_marker
    computer_marker = (human_marker.upcase == MARKER_O) ? MARKER_X : MARKER_O
    @human = Player.new(human_marker, name)
    @computer = Player.new(computer_marker, name == 'Daisy' ? 'Hal' : 'Daisy')
    @first_player = solicit_first_player
  end

  def solicit_continuation(text = 'continue')
    prompt = 'Type q to quit, h for help, or press Enter or Return to ' \
             "#{text} match."
    error = 'Invalid choice. Please choose q, h, or press Enter or Return.'
    Match.get_validated_input(prompt, error) { |input| input.empty? }
    Screen.clear
  end

  def solicit_first_player
    prompt = 'Do you want to go first in the first game (y/n)?'
    error = 'Incorrect response. Please enter y, n, q, or h.'
    go_first = Match.get_validated_input(prompt, error) do |input|
      %w(y Y n N).include?(input)
    end
    %w(y Y).include?(go_first) ? @human : @computer
  end

  def solicit_human_marker
    puts Text.word_wrap(<<~END), ''
      You may use any marker character you wish except h, H, q, Q, or a space.
      Be careful, though - pick a character that will be visible.
    END

    prompt = 'Which character do you want to use as a marker?'
    error = 'That character is not available. Try another marker character.'
    Match.get_validated_input(prompt, error) do |input|
      input.size == 1 && input != Square::INITIAL_MARKER
    end
  end

  def solicit_human_name
    prompt = 'What is your name?'
    error = 'Please enter your name.'
    Match.get_validated_input(prompt, error) do |input|
      !input.empty?
    end
  end

  def update_score(winning_player)
    winning_player.wins += 1 if winning_player
  end
end

#------------------------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME
  match = Match.new
  match.play
end
