require_relative 'searchable'
require 'active_support/inflector'
  

class AssocOptions < SQLObject
  attr_accessor :foreign_key, :class_name, :primary_key

  # Uses inflector gem to create an object reference from the class string
  # "String" >> String
  def model_class
    @class_name.constantize
  end

  # Calls self.table_name on the String constant
  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  # BelongsToOptions.new(
  #    :reference, {
  #      className: "Reference",
  #      primary_key: :id,
  #      foreign_key: :reference_id
  #    }
  # )

  # Creates a new BelongsToOptions object and assigns options to the
  # inherited AssocOptions attr_accessors with overwritable defaults
  def initialize(name, options = {})
    default = {
      class_name: "#{name.to_s.camelcase.singularize}",
      primary_key: :id,
      foreign_key: (name.to_s.downcase + "_id").to_sym
    }
    options = default.merge(options)
    options.each do |ivar, value|
      send("#{ivar}=", value)
    end
  end
end

class HasManyOptions < AssocOptions
  # HasManyOptions.new (
  #   :references, {
  #     class_name: "Reference",
  #     primary_key: :id,
  #     foreign_key: :selfclass_id
  #   }
  # )

  # Creates a new HasManyOptions object and assigns options to the
  # inherited AssocOptions attr_accessors with overwritable defaults
  def initialize(name, self_class_name, options = {})
    default = {
      class_name: "#{name.to_s.camelcase.singularize}",
      primary_key: :id,
      foreign_key: (self_class_name.to_s.downcase + "_id").to_sym
    }
    options = default.merge(options)
    options.each do |ivar, value|
      send("#{ivar}=", value)
    end
  end
end

module Associatable

  # establishes dynamically generated SQLobject belongs_to method
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options

    define_method(name) do
      klass = options.send :model_class
      f_key = options.send :foreign_key
      p_key = options.send :primary_key
      object = klass.where(p_key => send(f_key)).first
    end
  end

  # establishes dynamically generated SQLobject has_many method
  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    self.assoc_options[name] = options

    define_method(name) do
      klass = options.send :model_class
      f_key = options.send :foreign_key
      p_key = options.send :primary_key
      object = klass.where(f_key => send(p_key))
    end
  end

  # hashed options to persist AssocOptions association values
  def assoc_options
    @assoc_options ||= {}
  end

  # establishes dynamically generated method name which first queries the
  # assoc_options to get the table_name and values of both, and then makes
  # and SQL query to retrieve and format the results.
  def has_one_through(name, through_name, source_name)
    define_method(name) do

      through_opts = self.class.assoc_options[through_name]
      thru_table = through_opts.table_name
      thru_pid = through_opts.primary_key
      thru_fid = through_opts.foreign_key

      source_opts = through_opts.model_class.assoc_options[source_name]
      source_table = source_opts.table_name
      source_pid = source_opts.primary_key
      source_fid = source_opts.foreign_key

      assoc_value = self.send(thru_fid)

      results = DBConnection.execute(<<-SQL, assoc_value)
        SELECT #{source_table}.*
        FROM #{thru_table}
        JOIN #{source_table}
        ON #{thru_table}.#{source_fid} = #{source_table}.#{source_pid}
        WHERE #{thru_table}.#{thru_pid} = ?
      SQL

      source_opts.model_class.parse_all(results).first
    end
  end

end

class SQLObject
  extend Associatable
end
