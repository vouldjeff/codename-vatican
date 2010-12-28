class Entity
  include MongoMapper::Document
  
  key :key, String, :required => true, :unique => true
  key :namespace, String, :required => true
  key :title, String, :required => true
  key :description, String, :required => true
  key :properties, Hash # {:key => {:name => nil, :property-key => {:label => nil, :value => nil, :range => nil}}}
  key :aliases, Array
  key :image, String
  
  before_validation_on_create :create_key
  
  attr_accessible :nil
  
  def self.add_new_type(entity, type)
    type_skeleton = Type.get_skeleton(type)  
    unless type_skeleton["inherits"].nil?
      type_skeleton["inherits"].each do |parent|
        add_new_type(entity, parent)
      end
    end
    type_skeleton.delete("inherits")
    
    result = collection.update({"key" => entity, "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      {"$set" => {"properties" => {type => type_skeleton}}}, :safe => true)
      
    successful_update? result
  end
  
  def self.set_or_add_property_value(entity, type, property, value)
    is_child = false # TODO: write a method to figure it out
    
    child = (is_child) ? ".range" : ""
    
    type_definition = Type.collection.find_one({"key" => type, "type_properties" + child + ".key" => property},
      :fields => ["type_properties" + child + ".range", "type_properties" + child + ".unique", "type_properties" + child + ".key"])
      
    if type_definition.nil?
      raise_error!
    end
    
    type_property = nil
    type_definition["type_properties"].each do |p|
      if is_child
        if p["range"]["key"] == property
          type_property = p
          break
        end
      else
        if p["key"] == property
          type_property = p
          break
        end
      end
    end
    
    if type_property.nil?
      raise_error!
    end
    
    if type_property["range"].kind_of?(Array)
      unless value.kind_of?(Hash)
        raise_error!
      end
      keys = type_property["range"].collect(&:key)
      value_keys = value.keys
      result = (keys | value_keys) - (keys & value_keys)
      unless result.length == 0
        raise_error!
      end
    elsif type_property["range"].kind_of?(Hash)
      if type_property["range"]["type"] == "/base/ref" || type_property["range"]["type"] == "/base/reverse_ref"
        referenced_entity = collection.find_one({"key" => value, "properties." + type => {"$exists" => true}},
          :fields => ["key", "title"])
        if referenced_entity.nil?
          raise_error!
        end
        value_to_set = {"key" => referenced_entity["key"], "text" => referenced_entity["title"]}
      end
    end
    
    operation = (referenced_entity["unique"] == true) ? "set" : "push"
    property_path = "properties." + type + "." + property
    result = collection.update({"key" => entity, property_path => {"$exists" => true}, "$atomic" => true}, 
      {"$" + operation => {property_path + ".value" => value_to_set}}, :safe => true)
        
    successful_update? result
  end
  
  def self.raise_error!
    raise WrongOperationError, 
        "Wrong operation on the provided property."
  end
  
  def self.successful_update?(result)
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "entity with the provided criteria was not found."
    end
  end
  
  def self.remove_non_unique_property_at_position(entity, type, property, position)
    # TODO: write
  end
  
  private
  def create_key
    if key.nil? and !namespace.nil? and !title.nil?
      self.key = "/" + namespace + "/" + KeyGenerator.generate_from_string(title) 
    end
  end
end