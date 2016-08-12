# Pete Hanson

module Input
  def self.get(prompt, error, &validate)
    get_and_convert prompt, error, validate
  end

  def self.get_downcase(prompt, error, &validate)
    get_and_convert prompt, error, validate, &:downcase
  end

  private # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def self.get_and_convert(prompt, error, validate)
    input = prompt_and_get prompt
    loop do
      input = yield input if block_given?
      break input if validate.call input
      input = prompt_and_get error
    end
  end

  def self.prompt_and_get(prompt)
    puts prompt
    print '> '
    input = gets&.chomp || exit
    exit if %w(q Q).include? input
    puts
    input
  end
end
