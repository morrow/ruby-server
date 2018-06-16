def get_content_types
  obj = {
    :txt => 'text/plain',
    :html => 'text/html',
    :json => 'application/json',
    :js => 'application/javascript',
    :css => 'text/css',
    :jpg => 'image/jpeg',
    :svg => 'image/svg+xml',
    :png => 'image/png',
    :ico => 'image/x-icon',
  }
  %w(eot woff ttf eot).each do |font|
    obj[font.to_sym] = "application/x-font-#{font}"
  end
  return obj
end 