def indexHandler(request, response)
  response[:body] = {"main" => "Hello World"}
end

def aboutHandler(request, response)
  response[:body] = "about"
end

def contactHandler(request, response)
  response[:body] = {
  }
end