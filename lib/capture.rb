# Pete Hanson
#
# Intended for use by my unit tests
#
# Example usage:
#
# got_eof = nil
# result = nil
# output = stdout do
#   got_eof = eof do
#     stdin(*inputs) { result = yield }
#   end
# end
#
# eof, output, result = inout(*inputs) { input and output ops }

require 'stringio'

require_relative 'debug'

module Capture

  def self.eof?
    yield
    false
  rescue SystemExit
    true
  end

  def self.stderr(&handler)
    output($stderr, handler) { |value| $stderr = value }
  end

  def self.stdin(*strings)
    set_stdin_proc = proc { |value| $stdin = value }
    capture $stdin, set_stdin_proc do
      input = strings.join "\n"
      input << "\n" unless strings.empty?
      $stdin = StringIO.new(input)
      yield
    end
  end

  def self.stdio(*inputs)
    got_eof = nil
    result = nil
    out = stdout { got_eof = eof? { stdin(*inputs) { result = yield } } }
    return got_eof, out, result # rubocop:disable RedundantReturn
  end

  def self.stdout(&handler)
    output($stdout, handler) { |value| $stdout = value }
  end

  private # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def self.capture(stream, set_stream_proc)
    save_stream = stream
    yield
  ensure
    set_stream_proc.call save_stream
  end

  def self.output(stream, handler, &set_stream_proc)
    capture stream, set_stream_proc do
      mock_stream = StringIO.new
      set_stream_proc.call mock_stream
      handler.call
      mock_stream.string.gsub(/[ \t](?:\n|\Z)/, "\n")
    end
  end
end
