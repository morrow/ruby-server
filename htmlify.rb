def htmlify(title, body)
  """
  <!DOCTYPE html>
  <html>
    <head>
      <title>#{title}</title>
      <meta charset=\"utf-8\" />
    </head>
    <body>#{body}</body>
  </html>
  """.lstrip.chomp
end