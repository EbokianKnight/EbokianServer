require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  # def self.columns
  #   results = DBConnection.execute2(<<-SQL)
  #     SELECT *
  #     FROM #{table_name}
  #   SQL
  #   results.first.map(&:to_sym)
  # end
  def self.columns
    @column ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT *
      FROM #{table_name}
    SQL
  end

  def self.finalize!
    columns.each do |ivar|
      define_method(ivar) do
        instance_variable_get("@#{ivar}")
      end

      define_method("#{ivar}=") do |value|
        instance_variable_set("@#{ivar}")
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    name = self.to_s.tableize
    @table_name ||= name
  end

  def self.all
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    DBConnection.execute2(<<-SQL)

    SQL
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
