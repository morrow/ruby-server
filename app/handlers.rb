require './datastore'

def aboutHandler(request, response)
  return response
end

def assetHandler(request, response)
  return response
end

def indexHandler(request, response)
  response[:text] = 'test'
  return response
end

def projectHandler(request, response)
  return response
end

def contactHandler(request, response)
  ds = DataStore.new(:development, true)
  response[:body] = {
    :email => ds.cms_get('email'),
    :skype => ds.cms_get('skype'),
    :phone => ds.cms_get('phone'),
  }
  ds.close
  return response
end
