# Pete Hanson

module Debug
  def self.dump(value)
    from = caller.to_s.sub(/:in `.*/, '').sub(/^\["/, '')
    $stderr.puts "#{from}: #{value.inspect}"
    value
  end
end
