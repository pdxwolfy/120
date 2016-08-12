class Player
  attr_reader :move, :name

  def game_winner(other)
    return other if move < other.move
    return self  if move > other.move
  end

  def human?
    false
  end

  def ==(other)
    return false unless other # must compare false against nil
    @name == other.name && !human? == !other.human?
  end

protected

  attr_writer :move

private

  def initialize(name)
    @name = name
    @wins = 0
  end
end
