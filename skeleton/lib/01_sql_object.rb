require_relative 'db_connection'
require 'active_support/inflector'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @column ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT *
      FROM #{table_name}
    SQL
  end

  def self.finalize!
    columns.each do |ivar|
      define_method(ivar) do
        attributes[ivar]
      end

      define_method("#{ivar}=") do |value|
        attributes[ivar] = value
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
    results = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    parse_all(results)
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
      LIMIT 1
    SQL
    parse_all(results).pop
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include? attr_name.to_sym
        raise "unknown attribute '#{attr_name}'"
      end
      send("#{attr_name}=", value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{attributes.keys.join(', ')})
      VALUES (#{(["?"]*attributes.length).join(', ')})
    SQL
    self.id = DBConnection.instance.last_insert_row_id
  end

  def update
    DBConnection.execute(<<-SQL, *attribute_values)
      UPDATE #{self.class.table_name}
      SET #{self.class.columns.map{|c| "#{c} = ?" }.join(', ')}
      WHERE id = #{self.id}
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
