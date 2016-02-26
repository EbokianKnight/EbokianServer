require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
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
