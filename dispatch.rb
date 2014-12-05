require 'json'
require './handlers.rb'
require './htmlify.rb'

def dispatch(request)
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
  else
    request[:path] = request[:url]
  end
  # file extension
  request[:file_extension] = 'html'
  if request[:path].match(/\./)
    request[:file_extension] = request[:path].split('/').last.split('.')[1] 
    request[:path] = request[:path].split(".#{request[:file_extension]}")[0]
  end
  # controller
  request[:controller] = request[:path].split('/').reject{ |x| x.empty? }.first.downcase
  request[:controller] = "index" if not request[:controller]
  # content_types
  content_types = {
    :html => 'text/html',
    :json => 'application/json'
  }
  # setup response object
  response = {
    :status => 200,
    :content_type => content_types[request[:file_extension].to_sym],
    :title => request[:controller].gsub('/', ' ')
  }

  # handlers
  case request[:controller]
  when 'index'
    indexHandler(request, response)
  when 'about'
    aboutHandler(request, response)
  when 'contact'
    contactHandler(request, response)
  else
    response[:status] = 404
    response[:body] = "Not Found"
  end

  # json response
  if response[:content_type] == 'application/json'
    if response[:body].is_a? String
      response[:body] = JSON.generate({response[:body] => ''})
    elsif response[:body].is_a? Object or response[:body].is_a? Array
      response[:body] = JSON.generate(response[:body])
    end
  # html response
  elsif response[:content_type] = 'text/html'
    response[:body] = htmlify(response[:title], response[:body])
  end

  return response
end