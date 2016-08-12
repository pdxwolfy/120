# Pete Hanson
#
# Intended for use by my unit tests
# capture_stdin and capture_stdout have been stolen from public internet posts
# capture inout and capture_eof are mine

require 'stringio'

def capture_eof
  yield
  false
rescue SystemExit
  true
end

def capture_inout(*inputs)
  got_eof = nil
  result = nil
  output = capture_stdout do
    got_eof = capture_eof do
      capture_stdin(*inputs) { result = yield }
    end
  end

  [got_eof, output, result]
end

def capture_stdin(*strings)
  save_in = $stdin
  $stdin = StringIO.new(strings.empty? ? '' : (strings.join("\n") + "\n"))
  yield
ensure
  $stdin = save_in
end

def capture_stdout
  save_out = $stdout
  $stdout = mock_out = StringIO.new
  yield
  mock_out.string.gsub(/[ \t]\n/, "\n").gsub(/[ \t]\Z/, '')
ensure
  $stdout = save_out
end
