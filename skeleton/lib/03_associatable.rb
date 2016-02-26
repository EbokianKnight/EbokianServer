require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions < SQLObject
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    # ...
  end

  def table_name
    # ...
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {
      class_name: "#{name.camelcase.singularize}",
      primary_key: :id,
      foreign_key: (name.downcase + "_id").to_sym
    }
    options = default.merge(options)
    options.each do |ivar, value|
      send("#{ivar}=", value)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {
      class_name: "#{name.camelcase.singularize}",
      primary_key: :id,
      foreign_key: (self_class_name.downcase + "_id").to_sym
    }
    options = default.merge(options)
    options.each do |ivar, value|
      send("#{ivar}=", value)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    @options = BelongsToOptions.new(name, options)
  end

  def has_many(name, options = {})
    @options = HasManyOptions.new(name, options)
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  #extend AssocOptions
end
