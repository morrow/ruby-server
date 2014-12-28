def get_content_types
  return {
    :txt => 'text/plain',
    :html => 'text/html',
    :json => 'application/json',
    :js => 'application/javascript',
    :css => 'text/css',
    :jpg => 'image/jpeg',
    :svg => 'image/svg+xml',
    :png => 'image/png',
    :ico => 'image/x-icon'
  }
end