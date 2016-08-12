# Pete Hanson

require 'minitest/autorun'

require_relative 'capture'
require_relative 'input'

#------------------------------------------------------------------------------

class TestInputGet < Minitest::Test
  def setup
    @prompt = 'Four score and seven years ago:'
    @error = 'That is an error.'
  end

  def test_eof
    eof, output, result = capture_inout do
      Input.get(@prompt, @error) { abort }
    end
    assert eof
    assert_equal "#{@prompt}\n>", output
    assert_nil result
  end

  def test_valid_answer
    eof, output, result = capture_inout('y') do
      Input.get(@prompt, @error) { |input| input == 'y' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n", output
    assert_equal 'y', result
  end

  def test_invalid_answer_then_eof
    eof, output, result = capture_inout('Y') do
      Input.get(@prompt, @error) { |input| input == 'y' }
    end
    assert eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>", output
    assert_nil result
  end

  def test_invalid_invalid_then_valid
    eof, output, result = capture_inout('oNLY', 'only', 'Only') do
      Input.get(@prompt, @error) { |input| input == 'Only' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n#{@error}\n>\n", output
    assert_equal 'Only', result
  end
end

#------------------------------------------------------------------------------

class TestInputGetDowncase < Minitest::Test
  def setup
    @prompt = 'Four score and seven years ago:'
    @error = 'That is an error.'
  end

  def test_eof
    eof, output, result = capture_inout do
      Input.get_downcase(@prompt, @error) { abort }
    end
    assert eof
    assert_equal "#{@prompt}\n>", output
    assert_nil result
  end

  def test_valid_answer
    eof, output, result = capture_inout('Y') do
      Input.get_downcase(@prompt, @error) { |input| input == 'y' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n", output
    assert_equal 'y', result
  end

  def test_invalid_answer_then_eof
    eof, output, result = capture_inout('N') do
      Input.get_downcase(@prompt, @error) { |input| input == 'y' }
    end
    assert eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>", output
    assert_nil result
  end

  def test_invalid_invalid_then_valid
    eof, output, result = capture_inout('no', 'yes', 'only') do
      Input.get_downcase(@prompt, @error) { |input| input == 'only' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n#{@error}\n>\n", output
    assert_equal 'only', result
  end
end
