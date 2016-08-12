# Pete Hanson

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require_relative 'capture'
require_relative 'input'

#------------------------------------------------------------------------------

class TestInputGet < Minitest::Test
  def setup
    @prompt = 'Four score and seven years ago:'
    @error = 'That is an error.'
  end

  def test_eof
    eof, output, result = Capture.stdio { Input.get(@prompt, @error) { abort } }
    assert eof
    assert_equal "#{@prompt}\n>\n", output, output.inspect
    assert_nil result
  end

  def test_valid_answer
    eof, output, result = Capture.stdio('y') do
      Input.get(@prompt, @error) { |input| input == 'y' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n", output, output.inspect
    assert_equal 'y', result
  end

  def test_invalid_answer_then_eof
    eof, output, result = Capture.stdio('Y') do
      Input.get(@prompt, @error) { |input| input == 'y' }
    end
    assert eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n", output, output.inspect
    assert_nil result
  end

  def test_invalid_invalid_then_valid
    eof, output, result = Capture.stdio('oNLY', 'only', 'Only') do
      Input.get(@prompt, @error) { |input| input == 'Only' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n#{@error}\n>\n", output,
                 output.inspect
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
    eof, output, result = Capture.stdio do
      Input.get_downcase(@prompt, @error) { abort }
    end
    assert eof
    assert_equal "#{@prompt}\n>\n", output, output.inspect
    assert_nil result
  end

  def test_valid_answer
    eof, output, result = Capture.stdio('Y') do
      Input.get_downcase(@prompt, @error) { |input| input == 'y' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n", output, output.inspect
    assert_equal 'y', result
  end

  def test_invalid_answer_then_eof
    eof, output, result = Capture.stdio('N') do
      Input.get_downcase(@prompt, @error) { |input| input == 'y' }
    end
    assert eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n", output, output.inspect
    assert_nil result
  end

  def test_invalid_invalid_then_valid
    eof, output, result = Capture.stdio('no', 'yes', 'only') do
      Input.get_downcase(@prompt, @error) { |input| input == 'only' }
    end
    refute eof
    assert_equal "#{@prompt}\n>\n#{@error}\n>\n#{@error}\n>\n", output,
                 output.inspect
    assert_equal 'only', result
  end
end
