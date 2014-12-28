require 'sqlite3'

def cms_get(key)
  db = SQLite3::Database.open 'db/development.db'
  begin
    query =  "SELECT (key, value) FROM 'cms' WHERE(key='#{key}');"
    return db.execute(query)
  rescue => e
    return nil
  end
  db.close
end