require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  # allows database search using variable parameters
  def where(params)
    table = self.table_name
    results = DBConnection.execute(<<-SQL, params)
      SELECT *
      FROM #{table}
      WHERE #{params.map{|k,_| "#{table}.#{k} = :#{k}" }.join(' AND ')}
    SQL
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
