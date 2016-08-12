require 'stringio'
require_relative 'tictactoe'
require 'minitest/autorun'

## rubocop:disable AbcSize
## rubocop:disable MethodLength

def capture_eof
  yield
  false
rescue SystemExit
  true
end

def capture_input_output(*inputs)
  got_eof = nil
  result = nil
  output = capture_stdout do
    got_eof = capture_eof do
      capture_stdin(*inputs) { result = yield }
    end
  end

  [got_eof, output, result]
end

def capture_stdin(*strings)
  save_in = $stdin
  $stdin = StringIO.new(strings.empty? ? '' : (strings.join("\n") + "\n"))
  yield
ensure
  $stdin = save_in
end

def capture_stdout
  save_out = $stdout
  $stdout = mock_out = StringIO.new
  yield
  mock_out.string
ensure
  $stdout = save_out
end

def fill_board(board, plays)
  plays.each_pair do |marker, keys|
    keys.each { |key| board[key] = marker.to_s }
  end
end

class String
  def strip_trailing_spaces
    gsub(/ +$/, '')
  end
end

#------------------------------------------------------------------------------

BOARD_3X3_EMPTY = <<'END'
     |     |
     |     |
     |     |
-----+-----+-----
     |     |
     |     |
     |     |
-----+-----+-----
     |     |
     |     |
     |     |
END

BOARD_3X3_IN_PLAY = <<'END'
     |     |
  X  |  O  |
     |     |
-----+-----+-----
     |     |
     |  O  |  *
     |     |
-----+-----+-----
     |     |
  O  |  X  |  X
     |     |
END

#------------------------------------------------------------------------------

class TestTextJoinOr < Minitest::Test
  def test_empty_list
    assert_equal '', Text.join_or([])
  end

  def test_one_item_list
    assert_equal 'abc', Text.join_or(%w(abc))
  end

  def test_two_item_list
    assert_equal 'abc or def', Text.join_or(%w(abc def))
  end

  def test_two_item_list_with_and
    assert_equal 'abc and def', Text.join_or(%w(abc def), ', ', 'and')
  end

  def test_two_item_list_with_sep
    assert_equal 'abc and def', Text.join_or(%w(abc def), '/', 'and')
  end

  def test_three_item_list
    assert_equal 'abc, xyz, or def', Text.join_or(%w(abc xyz def))
  end

  def test_three_item_list_with_and
    assert_equal 'abc, xyz, and def',
                 Text.join_or(%w(abc xyz def), ', ', 'and')
  end

  def test_three_item_list_with_sep
    assert_equal 'abc/xyz/def', Text.join_or(%w(abc xyz def), '/', '')
  end
end

#------------------------------------------------------------------------------

class TestPlayer < Minitest::Test
  def test_create_x
    player = Player.new('X', 'Pete')
    assert_equal 'X', player.marker
  end

  def test_create_o
    player = Player.new('O', 'Daisy')
    assert_equal 'O', player.marker
  end

  def test_create_star
    player = Player.new('*', 'Pete')
    assert_equal '*', player.marker
  end
end

#------------------------------------------------------------------------------

class TestSquareMarker < Minitest::Test
  def test_initial_marker
    assert_equal ' ', Square::INITIAL_MARKER
  end

  def test_create_unmarked
    square = Square.new
    assert_equal Square::INITIAL_MARKER, square.marker
  end

  def test_create_marked
    square = Square.new('*')
    assert_equal '*', square.marker
  end
end

#------------------------------------------------------------------------------

class TestSquareUnmarked < Minitest::Test
  def test_create_unmarked
    square = Square.new
    assert square.unmarked?
  end

  def test_create_marked
    square = Square.new('*')
    refute square.unmarked?
  end
end

#------------------------------------------------------------------------------

class TestSquareToS < Minitest::Test
  def test_create_unmarked
    square = Square.new
    assert_equal ' ', square.to_s
  end

  def test_create_marked
    square = Square.new('X')
    assert_equal 'X', square.to_s
  end
end

#------------------------------------------------------------------------------

class TestBoardNew < Minitest::Test
  def test_new
    board = Board.new
    assert board
  end
end

#------------------------------------------------------------------------------
# NOTE: Tests Board#[]= and Board#squares_at

class TestBoardMarkSquaresAt < Minitest::Test
  def setup
    @board = Board.new
    fill_board(@board, X: [1, 8, 9], O: [2, 5, 7], '*' => [6])
  end

  def test_marking_x
    assert_equal [Square.new('X'), Square.new('X'), Square.new('X')],
                 @board.squares_at(1, 8, 9)
  end

  def test_marking_o
    assert_equal [Square.new('O'), Square.new('O'), Square.new('O')],
                 @board.squares_at(2, 5, 7)
  end

  def test_marking_star
    assert_equal [Square.new('*')], @board.squares_at(6)
  end

  def test_marking_unmarked
    assert_equal [Square.new(' '), Square.new(' ')], @board.squares_at(3, 4)
  end

  def test_marking_mixed
    assert_equal [Square.new('X'), Square.new('O'), Square.new('*'),
                  Square.new(' ')],
                 @board.squares_at(1, 5, 6, 4)
  end
end

#------------------------------------------------------------------------------

class TestBoardDisplay < Minitest::Test
  def test_empty
    board = Board.new
    output = capture_stdout { board.display }
    assert_equal BOARD_3X3_EMPTY, output.strip_trailing_spaces
  end

  def test_in_play
    board = Board.new
    fill_board(board, X: [1, 8, 9], O: [2, 5, 7], '*' => [6])
    output = capture_stdout { board.display }
    assert_equal BOARD_3X3_IN_PLAY, output.strip_trailing_spaces
  end
end

#------------------------------------------------------------------------------

class TestBoardUnmarkedKeysIn < Minitest::Test
  def test_it
    board = Board.new
    fill_board(board, X: [3, 5], O: [2, 4])
    assert_equal [1, 7, 8, 9], board.unmarked_keys_at([1, 7, 8, 9])
    assert_equal [1, 6],       board.unmarked_keys_at((1..6).to_a)
    assert_equal [],           board.unmarked_keys_at((2..5).to_a)
  end
end

#------------------------------------------------------------------------------

class TestBoardFullQuery < Minitest::Test
  def test_empty
    board = Board.new
    refute board.full?
  end

  def test_partial
    board = Board.new
    fill_board(board, X: [1, 8, 9], O: [2, 5, 7], '*' => [6])
    refute board.full?
  end

  def test_full
    board = Board.new
    fill_board(board, X: [1, 8, 9, 3], O: [2, 5, 7, 4], '*' => [6])
    assert board.full?
  end
end

#------------------------------------------------------------------------------

class TestBoardCountMarkers < Minitest::Test
  def test_count
    board = Board.new
    fill_board(board, X: [1, 2, 5, 9], O: [3, 4, 6, 8])
    assert_equal({ 'X' => 2, 'O' => 1 }, board.count_markers([1, 2, 3]))
    assert_equal({ 'X' => 3 }, board.count_markers([1, 5, 9]))
    assert_equal({ 'X' => 3 }, board.count_markers([9, 5, 1]))
    assert_equal({ 'X' => 4, ' ' => 1 }, board.count_markers([1, 2, 5, 7, 9]))
  end
end

#------------------------------------------------------------------------------

class TestBoardWinningMarker < Minitest::Test
  def test_empty_board
    board = Board.new
    assert_nil board.winning_marker
  end

  def test_x_wins
    board = Board.new
    fill_board(board, X: [1, 2, 5, 9, 7], O: [3, 4, 6, 8])
    assert_equal 'X', board.winning_marker
  end

  def test_y_wins
    board = Board.new
    fill_board(board, X: [1, 2, 5, 9, 7], O: [3, 4, 6, 8])
    assert_equal 'X', board.winning_marker
  end

  def test_tie
    board = Board.new
    fill_board(board, X: [1, 2, 5, 7], O: [3, 4, 6, 8])
    assert_nil board.winning_marker
  end
end

#------------------------------------------------------------------------------

class TestSomeoneWon < Minitest::Test
  def test_count_empty_board
    board = Board.new
    refute board.someone_won?
  end

  def test_count_x_wins
    board = Board.new
    fill_board(board, X: [1, 2, 5, 9, 7], O: [3, 4, 6, 8])
    assert board.someone_won?
  end

  def test_count_y_wins
    board = Board.new
    fill_board(board, X: [1, 2, 5, 9, 7], O: [3, 4, 6, 8])
    assert board.someone_won?
  end

  def test_count_tie
    board = Board.new
    fill_board(board, X: [1, 2, 5, 7], O: [3, 4, 6, 8])
    refute board.someone_won?
  end
end

#------------------------------------------------------------------------------

class TestBoardNInARow < Minitest::Test
  def test_empty_board_with_x
    board = Board.new
    assert_equal [], board.in_a_row(1, 'X')
  end

  def test_empty_board_with_o
    board = Board.new
    assert_equal [], board.in_a_row(2, 'O')
  end

  def test_full_board_no_winners_with_x
    board = Board.new
    fill_board(board, X: [1, 3, 4, 8, 9], O: [2, 5, 6, 7])
    assert_equal [], board.in_a_row(1, 'X')
  end

  def test_full_board_no_winners_with_o
    board = Board.new
    fill_board(board, X: [1, 3, 4, 8, 9], O: [2, 5, 6, 7])
    assert_equal [], board.in_a_row(1, 'O')
  end

  def test_nearly_full_board_with_one_x_winner_available
    board = Board.new
    fill_board(board, X: [1, 4, 6, 8], O: [2, 3, 5, 9])
    assert_equal [],          board.in_a_row(1, 'X')
    assert_equal [[1, 4, 7]], board.in_a_row(2, 'X')
    assert_equal [],          board.in_a_row(3, 'X')
  end

  def test_nearly_full_board_with_one_y_winner_available
    board = Board.new
    fill_board(board, X: [1, 4, 6, 8], O: [2, 3, 5, 9])
    assert_equal [],          board.in_a_row(1, 'O')
    assert_equal [[3, 5, 7]], board.in_a_row(2, 'O')
    assert_equal [],          board.in_a_row(3, 'O')
  end

  def test_board_with_multiple_x_winners_available
    board = Board.new
    fill_board(board, X: [1, 9], O: [3, 5])
    assert_equal [[7, 8, 9], [1, 4, 7]], board.in_a_row(1, 'X')
    assert_equal [],                     board.in_a_row(2, 'X')
  end

  def test_board_with_multiple_o_winners_available
    board = Board.new
    fill_board(board, X: [1, 9], O: [3, 5])
    assert_equal [[4, 5, 6], [2, 5, 8]], board.in_a_row(1, 'O')
    assert_equal [[3, 5, 7]],            board.in_a_row(2, 'O')
    assert_equal [],                     board.in_a_row(3, 'O')
  end

  def test_board_with_x_winner
    board = Board.new
    fill_board(board, X: [1, 5, 7], O: [3, 6, 8])
    assert_equal [],                     board.in_a_row(1, 'X')
    assert_equal [[1, 4, 7], [1, 5, 9]], board.in_a_row(2, 'X')
    assert_equal [],                     board.in_a_row(3, 'X')
  end

  def test_board_with_o_winner
    board = Board.new
    fill_board(board, O: [1, 5, 7], X: [3, 6, 8])
    assert_equal [],                     board.in_a_row(1, 'O')
    assert_equal [[1, 4, 7], [1, 5, 9]], board.in_a_row(2, 'O')
    assert_equal [],                     board.in_a_row(3, 'O')
  end
end

#------------------------------------------------------------------------------
# Private method test

class TestComputerMoveChooserRandomMove < Minitest::Test
  include ComputerMoveChooser
  attr_reader :board, :human, :computer

  def setup
    @board = Board.new
    @human = Player.new('X', 'Pete')
    @computer = Player.new('O', 'Daisy')
  end

  def test_random_move
    available = (1..9).to_a
    9.times do |index|
      key = random_move
      assert available.include?(key)
      board[key] = index.even? ? 'X' : 'O'
      available.delete(key)
    end
  end
end

#------------------------------------------------------------------------------
# Private method test

class TestComputerMoveChooserCenterMove < Minitest::Test
  include ComputerMoveChooser
  attr_reader :board, :degree

  def setup
    @board = Board.new
  end

  def test_middle_is_available
    assert_equal 5, center_move
  end

  def test_middle_is_not_available
    @board[5] = 'O'
    assert_nil center_move
  end
end

#------------------------------------------------------------------------------
# Private method test

class TestComputerMoveChooserOffensiveMove < Minitest::Test
  include ComputerMoveChooser
  attr_reader :board, :human, :computer

  def setup
    @board = Board.new
    @human = Player.new('X', 'Pete')
    @computer = Player.new('O', 'Daisy')
  end

  def test_offensive_empty_board
    assert_nil offensive_move
  end

  def test_offensive_0_winning_play
    fill_board(board, X: [1], O: [5])
    assert_nil offensive_move
  end

  def test_offensive_1_winning_play
    fill_board(board, X: [1, 2, 4, 9], O: [3, 5, 6])
    assert_equal 7, offensive_move
  end

  def test_offensive_2_winning_plays
    @human = Player.new('O', 'Daisy')
    @computer = Player.new('X', 'Pete')
    fill_board(board, O: [2, 4, 6], X: [1, 3, 5])
    available = [7, 9]
    available.size.times do
      board[choice = offensive_move] = 'X'
      assert available.include?(choice)
      available.delete(choice)
    end
    assert_equal [], available
  end

  def test_offensive_5_winning_plays
    @human = Player.new('O', 'Daisy')
    @computer = Player.new('X', 'Pete')
    fill_board(board, X: [1, 3, 7, 9])
    available = [2, 4, 5, 6, 8]
    available.size.times do
      board[choice = offensive_move] = 'X'
      assert available.include?(choice)
      available.delete(choice)
    end
    assert_equal [], available
  end
end

#------------------------------------------------------------------------------
# Private method test

class TestComputerMoveChooserDefensiveMove < Minitest::Test
  include ComputerMoveChooser
  attr_reader :board, :human, :computer

  def setup
    @board = Board.new
    @human = Player.new('X', 'Pete')
    @computer = Player.new('O', 'Hal')
  end

  def test_defensive_empty_board
    assert_nil defensive_move
  end

  def test_defensive_0_play
    fill_board(board, X: [1], O: [5])
    assert_nil defensive_move
  end

  def test_defensive_1_play
    fill_board(board, X: [1, 2, 4, 9], O: [3, 5, 6])
    assert_equal 7, defensive_move
  end

  def test_defensive_1_play_2
    fill_board(board, X: [1, 3, 4, 9], O: [2, 5, 6])
    assert_equal 7, defensive_move
  end

  def test_defensive_3_plays
    fill_board(board, X: [1, 7, 9], O: [2, 3, 6])
    available = [4, 5, 8]
    available.size.times do
      board[choice = defensive_move] = 'X'
      assert available.include?(choice)
      available.delete(choice)
    end
    assert_equal [], available
  end
end
