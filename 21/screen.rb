# Pete Hanson

module Screen
  def self.clear
    system('clear') || system('cls')
  end
end
