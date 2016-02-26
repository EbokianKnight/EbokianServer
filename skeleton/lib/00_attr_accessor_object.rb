class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |ivar|
      define_method("#{ivar}") do
        instance_variable_get("@#{ivar}")
      end

      define_method("#{ivar}=") do |value|
        instance_variable_set("@#{ivar}", value)
      end
    end
  end
end
