require 'socket'
require 'json'

server = TCPServer.new('localhost', 8093)

def handle(request)
  # parse query string
  if request[:url].match(/\?/)
    request[:query] = {}
    query_string = request[:url].split('?')[1]
    request[:path] = request[:url].split('?')[0]
    # key-value query string
    if query_string and query_string.match(/\=/)
      if query_string.match(/\&/)
        query_string.split('&').each do |key_value|
          key = key_value.split('=')[0]
          value = key_value.split('=')[1]
          request[:query][key] = value
        end
      else
        request[:query][query_string.split('=')[0]] = query_string.split('=')[1]
      end
    # query only string
    elsif query_string
      request[:query] = {query_string => ""}
    end
  end
  # file extension
  request[:file_extension] = 'html'
  if request[:path].match(/\./)
    request[:file_extension] = request[:path].split('/').last.split('.')[1] 
    request[:path] = request[:path].split(".#{request[:file_extension]}")[0]
  end
  # controller
  request[:controller] = request[:path].split('/').reject{ |x| x.empty? }.first
  # content_types
  content_types = {
    :html => 'text/html',
    :json => 'application/json'
  }
  # setup response object
  response = {
    :status => 200,
    :content_type => content_types[request[:file_extension].to_sym]
  }
  # handle request path
  case request[:controller]
  when /\//
    response[:body] = "Hello World"
  when /query/
    response[:body] = request[:query]
  when /debug/
    response[:body] = JSON.generate(request)
  else
    response[:status] = 404
    response[:body] = "Not Found"
  end
  return response
end

while socket = server.accept do 

  # create request object
  request = {
    :start_time => Time.now.to_f
  }

  # parse request line variables into request object
  request_line = socket.gets.split(" ") 

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

  # handle request
  response = handle(request)

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
