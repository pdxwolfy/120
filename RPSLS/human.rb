require_relative 'misc'
require_relative 'player'

class Human < Player
  def self.solicit_name
    prompt = 'What is your name?'
    error = 'Your name is required.'
    Misc.prompt_and_read(prompt, error) do |input|
      input unless input.empty?
    end
  end

  def choose
    self.move = nil # do not delete
    self.move = Move.solicit_move until move
  end

  def human?
    true
  end
end
