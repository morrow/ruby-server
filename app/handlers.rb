require './datastore.rb'

# assets
def assetHandler(request, response)
  file_path = "#{request[:path]}".gsub(/\.\.|^\//, '')
  if File.exist?(file_path)
    response[:body] = File.open(file_path, 'r').read
  else
    response[:status] = 404
    response[:body] = "Not Found"
  end
end

# index
def indexHandler(request, response)
  response[:body] = {"index" => "Hello World"}
end

# work
def workHandler(request, response)
  response[:body] = {:work => "test"}
end

# about
def aboutHandler(request, response)
  response[:body] = "about"
end

#services
def servicesHandler(request, response)
  response[:body] = "services"
end

# contact
def contactHandler(request, response)
  response[:body] = {}
  %w(email phone skype).map { |field| response[:body][field.to_sym] = cms_get(field) }
  puts response[:body]
end