require 'json'
require 'uri'
require './handlers.rb'
require './config/content_types.rb'

def dispatch(request)
  
  # parse URI
  uri = URI(request[:url])
  %w(scheme host port path query fragment).each do |key|
    request[key.to_sym] = uri.send(key.to_sym)
  end

  # controller
  request[:controller] = "index"
  if request[:path].match(/\//) and request[:path].split('/').length > 1
    request[:controller] = request[:path].split('/').reject{ |x| x.empty? }.first.downcase
  end

  # content_types
  content_types = get_content_types

  # setup response object
  response = {
    :status => 200,
    :content_type => content_types[File.extname(request[:path]).delete('.').to_sym],
    :title => request[:controller].gsub('/', ' ')
  }

  # default content type is html
  response[:content_type] = "text/html" if not response[:content_type]

  # handlers
  case request[:controller]
  when 'index'
    indexHandler(request, response)
  when 'about'
    aboutHandler(request, response)
  when 'contact'
    contactHandler(request, response)
  when 'assets'
    assetHandler(request, response)
  when 'work'
    workHandler(request, response)
  when 'services'
    servicesHandler(request, response)
  else
    response[:status] = 404
    response[:body] = "Not Found"
  end

  # html response
  if response[:content_type] == 'text/html'
    if response[:body].class == Hash
      obj = response[:body]
      response[:body] = ''
      if obj.keys.length > 1
        response[:body] = '<ul>'
        tag = 'li'
      else
        tag = 'div'
      end
      obj.each do |key, value|
        response[:body] += "<#{tag} class='#{key}'>#{value}</#{tag}>"
      end
      if response[0..4] == '<ul>'
        response[:body] += '</ul>'
      end 
    end
    # page template
    if File.exists?("templates/pages/#{request[:controller].to_s}.html")
      response[:body] = File.open("templates/pages/#{request[:controller].to_s}.html", "r").read % response
    end
    # application template
    response[:header] = File.open("templates/layout/header.html", "r").read % response
    #response[:footer] = File.open("templates/layout/footer.html", "r").read % response
    response[:body] = File.open("templates/layout/application.html", "r").read % response
  
  # json response
  elsif response[:content_type] == 'application/json'
    if response[:body].is_a? String
      response[:body] = JSON.generate({response[:body] => ''})
    elsif response[:body].is_a? Object or response[:body].is_a? Array
      response[:body] = JSON.generate(response[:body])
    end
  end

  return response

end