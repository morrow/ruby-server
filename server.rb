require 'socket' # Provides TCPServer and TCPSocket classes

# Initialize a TCPServer object that will listen
# for incoming connections.
server = TCPServer.new('localhost', 8093)

# loop infinitely, processing one incoming
# connection at a time.
loop do

  # Wait until a client connects, then return a TCPSocket
  # that can be used in a similar fashion to other Ruby
  # I/O objects. (In fact, TCPSocket is a subclass of IO.)
  socket = server.accept

  # Read the first line of the request (the Request-Line)
  request = socket.gets

  # Log the request to the console for debugging
  STDERR.puts request

  response_body = "Hello Vanessa!\n"

  # We need to include the Content-Type and Content-Length headers
  # to let the client know the size and type of data
  # contained in the response. Note that HTTP is whitespace
  # sensitive, and expects each header line to end with CRLF (i.e. "\r\n")
  protocol = "HTTP/1.1"
  status = "200 OK"
  end_of_line = "\r\n"
  content_type = "text/plain"
  content_length = response_body.bytesize

  response_headers =  ["#{protocol} #{status}", "Content-Type: #{content_type}", "Content-Length: #{content_length}", "Connection: close", ""].join(end_of_line)

  puts response_headers

  # Print a blank line to separate the header from the response body,
  # as required by the protocol.
  response = response_headers + "\r\n" + response_body
  puts response
  socket.print response


  # Close the socket, terminating the connection
  socket.close
end
