class TypeBuilder
  def initialize
    type = Type.new
  end
  
  def edit_type(type_param)
    type = type_param
    return self
  end
  
  def inherit(type)
    unless Type.is_valid_key?(type)
      raise UnknownTypeError, "Type with #{type} key was not found"
    end
    
    type.inherit << type
    return self
  end
  
  def set_key(value)
    type.key = value
    if Type.where(:key => value).limit(1).count() == 1
      type.key += " #{BSON::ObjectId.new.to_s}"
    end
    return self
  end
  
  def set_description(value)
    type.description = value
    return self
  end
  
  def set_name(value)
    type.name = value
    return self
  end
  
  def add_definition_property(base_type, name, is_array = false, description = nil)
    schema = PropertyTypes[base_type].respond_to?(:get_schema) ? PropertyTypes[base_type].get_schema : nil
    
    type.add_new_type_definition_property(name, base_type, is_array, schema, description)
    return self
  end
  
  def build()
    type
  end
end