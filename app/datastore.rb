require 'sqlite3'

class DataStore

  def initialize (db=:development, keep_alive=false)
    @connection = SQLite3::Database.open File.join($ROOT_DIR, "db/#{db}.db")
    @keep_alive = keep_alive
  end

  def runQuery(query, *args)
    begin
      return @connection.execute(query, *args)
    rescue => e
      return false
    ensure
      @connection.close unless @keep_alive
    end
  end

  def cms_get(key)
    return runQuery("SELECT value FROM 'cms' WHERE(key=?) LIMIT 1;", key).first.first
  end

  def cms_set(key, value)
    return runQuery "INSERT INTO 'cms' (key, value) VALUES(?, ?);", key, value
  end

  def getAll(key)
    return runQuery "SELECT value FROM 'cms' WHERE(key=?);", key
  end

  def close
    return @connection.close
  end

end
