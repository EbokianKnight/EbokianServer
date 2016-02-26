require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions < SQLObject

  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
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
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      klass = options.send :model_class
      f_key = options.send :foreign_key
      p_key = options.send :primary_key
      p p_key
      p f_key
      p self.class
      p klass
      p klass.where(p_key => send(f_key))
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, options)
    define_method(name) do
      klass = options.model_class
      f_key = options.foreign_key
      p_key = options.primary_key
      klass.where(f_key => send(p_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
