require 'socket'
require 'json'
require './dispatch.rb'

server = TCPServer.new('localhost', 8093)

while socket = server.accept do 

  # create request object
  request = {
    :start_time => Time.now.to_f
  }

  # parse request line variables into request object
  request_line = socket.gets
  next if not request_line
  request_line = request_line.split(" ") 

  %w(method url protocol).each_with_index do |key, index|
    request[key.to_sym] = request_line[index]
  end

  # populate request object from socket
  while line = socket.gets and line != "\r\n"
    request[line.split(':')[0].downcase.gsub('-', '_').to_sym] = line.split(':')[1].chomp
  end

  # IP
  request[:remote_address] = socket.addr.join(' ')
  request[:remote_ip] = socket.addr.last

  # status codes
  status_codes = [200, 404]

  # status code messages
  status_code_messages = {
    200 => "OK",
    404 => "Not Found"
  }

  # dispatch request
  response = dispatch(request)

  # response headers
  response[:headers] =  [
    "HTTP/1.1 #{response[:status]} #{status_code_messages[response[:status]]}",
    "Content-Type: #{response[:content_type]}",
    "Content-Length: #{response[:body].to_s.bytesize}",
    "Connection: close", 
    "X-Powered-By: Ruby", ""].join("\r\n")
  response = response[:headers] + "\r\n" + response[:body].to_s

  # print response and end connection
  socket.print response
  socket.close

  # logging
  puts "#{request[:url]} #{((Time.now.to_f - request[:start_time]) * 1000).round(2)}ms"

  # delete request, response, and socket objects
  request = nil
  response = nil
  socket = nil
  GC.start

end
