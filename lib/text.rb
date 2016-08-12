# Pete Hanson

module Text
  # Yes, I understand this. I can even write this from scratch, but I didn't.
  # I figured it was okay to steal it since it isn't a critical element of this
  # program. (I have enhanced it, adding the multi-paragraph capability, and
  # requiring that each "line" end with a non-whitespace character.)
  def self.word_wrap(text, width: 79, prefix: '')
    # matches 2 to width characters ending with a non-whitespace character,
    # and followed by whitespace or the end of string.
    one_line = /(.{1,#{width - 1}}\S)(?:\s+|\Z)/
    text.split("\n\n").map do |line|
      "#{prefix}#{line.gsub(/\s*\n\s*/, ' ').gsub(one_line, "\\1\n")}\n"
    end
  end
end
