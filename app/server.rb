require 'socket'
require 'json'
require './dispatch'

# add current directoy to load path for requires
$LOAD_PATH << File.dirname(__FILE__)
# set root directory
$ROOT_DIR = Dir.getwd
# modify root directory if server launched inside of app folder
if Dir.getwd.split('/').last.match /app/
  $ROOT_DIR = Dir.getwd.split('/')[0..-2].join('/')
end

# load views into memory
$VIEWS = {}
view_dir = File.join($ROOT_DIR, 'app/views/*/*.html')
Dir.glob(view_dir).each do |filename|
  puts filename
  $VIEWS[File.basename(filename, ".*")] = File.open(filename, 'r').read
end

# get port from arguments or set to default (8093)
PORT = 8093
PORT = ARGV.first if ARGV.length > 0 and ARGV.first.to_i >= 0 and ARGV.first.to_i <= 65535
server = TCPServer.new('localhost', PORT)
$stdout.puts "starting server on #{PORT}"

# start socket loop
while socket = server.accept do

  # grab first line from request
  request_line = socket.gets

  # avoid processing empty requests
  next if not request_line

  # split request line
  request_line = request_line.split(" ")

  # parse request line into request object
  request = {
    :error      =>  nil,             # processing error - nil unless there is a 500 error
    :start_time =>  Time.now.to_f,   # request starting time
    :method     =>  request_line[0], # request method (GET, POST, etc.)
    :url        =>  request_line[1], # url line (/assets/images/background.jpg?querystring)
    :protocol   =>  request_line[2]  # protocol (http, https, etc.)
  }

  # populate request object from socket
  while line = socket.gets and line != "\r\n"
    request[line.split(':')[0].downcase.gsub('-', '_').to_sym] = line.split(':')[1].chomp.lstrip
  end

  # populate port and IP fields
  request[:port] = socket.addr[1]
  request[:remote_address] = socket.addr.join(' ')
  request[:remote_ip] = socket.addr.last

  # include protocol and host in url
  request[:url] = "#{request[:protocol].downcase.split('/')[0]}://#{request[:host]}:#{request[:port]}#{request[:url]}"

  # status code messages
  status_code_messages = {
    200 => "OK",
    301 => "Moved Permanently",
    304 => "Not Modified",
    400 => "Bad Request",
    401 => "Unauthorized",
    403 => "Forbidden",
    404 => "Not Found",
    500 => "Internal Server Error"
  }

  # status codes
  status_codes = status_code_messages.keys

  begin

    # dispatch request
    response = dispatch(request)

  rescue => e

    # rescue from error
    response = {
      :status => 500,
      :content_type => 'text/html',
      :body => '500 Internal Error',
      :error => e
    }

  ensure

    # form response headers
    response[:headers] =  [
      "HTTP/1.1 #{response[:status]} #{status_code_messages[response[:status]]}",
      "Content-Type: #{response[:content_type]}",
      "Content-Length: #{response[:body].to_s.bytesize}",
      "Connection: close",
      "X-Powered-By: Ruby", ""].join("\r\n")

    # print response and body (if not a head request) and end connection
    socket.print response[:headers]
    socket.print "\r\n" + response[:body].to_s if request[:method] != 'HEAD'
    socket.close

    # logging
    $stdout.puts "#{request[:method]} #{request[:url]} #{response[:status]} #{((Time.now.to_f - request[:start_time]) * 1000).round(2)}ms"
    $stderr.puts response[:error] if response[:error]

    # delete request, response, and socket objects
    request = nil
    response = nil
    socket = nil
    GC.start

  end

end
