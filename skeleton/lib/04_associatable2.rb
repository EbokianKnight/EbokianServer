require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    debugger
    through_object = send(through_name)
    source_object = through_object.send(source_name)
  end
end
