module Misc
  def self.integer_in_range(value, range)
    integer_value = Integer(value)
    return integer_value if range.include?(integer_value)
  rescue ArgumentError
    nil
  end

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

  def self.prompt_and_read(the_prompt, error = nil)
    block = block_given? ? Proc.new : nil
    result = solicit(the_prompt, error, block) while result.nil?
    puts
    result
  end

  def self.select_from_list(the_prompt, the_list)
    prompt = [the_prompt]
    prompt += the_list.each_with_index.map do |item, index|
      format('   %2d.  %s', index + 1, item)
    end

    err = "Please choose an item between 1 and #{the_list.size}, or Q to quit."
    prompt_and_read(prompt.join("\n"), err) do |input|
      yield(input) if block_given?
      result = integer_in_range(input, 1..the_list.size)
      result - 1 if result
    end
  end

private

  def self.solicit(the_prompt, error, block)
    puts the_prompt
    print '> '

    input = gets&.chomp || exit
    result = block ? block.call(input) : input
    return result if result

    puts error if error
  end
end
