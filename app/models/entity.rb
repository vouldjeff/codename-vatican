class Entity
  include MongoMapper::Document
  
  key :key, String
  key :namespace, String, :required => true
  key :title, String, :required => true
  key :description, String, :required => true
  key :properties, Hash # {:key => {:name => nil, :type_properties => {:property-key => {:label => nil, :value => nil, :range => nil}}}}
  key :aliases, Array
  key :image, String
  
  before_validation :create_key, :on => :create
  
  validates_presence_of :key
  validates_uniqueness_of :key, :allow_nil => false
  
  attr_accessible :nil
  
  def to_triples
    triples = RdfTriplesBuilder.new key # TODO: fix to append domain name
    
    properties.each do |type_key, type|
      type["type_properties"].each do |property_key, property|
        unless property.kind_of? Array
          triples.add(property_key, property["value"])
        else
          property.each do |property|
            triples.add(property_key, property["value"])
          end
        end
      end
    end
    
    triples.to_a
  end
  
  def self.add_new_type(entity, type)
    type_skeleton = Type.get_skeleton(type)  
    unless type_skeleton["inherits"].nil?
      type_skeleton["inherits"].each do |parent|
        add_new_type(entity, parent)
      end
    end
    type_skeleton.delete("inherits")
    
    result = collection.update({"key" => entity, "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      {"$set" => {"properties." + type => type_skeleton}}, :safe => true)
      
    successful_update? result
  end
  
  def self.set_or_add_property_value(entity, type, property, value)
    type_definition = Type.collection.find_one({"key" => type, "type_properties.key" => property},
      :fields => ["type_properties.range", "type_properties.unique", "type_properties.key"])
      
    raise_error! if type_definition.nil?
    
    type_property = nil
    type_definition["type_properties"].each do |p|
      if p["key"] == property
        type_property = p
        break
      end
    end
    
    raise_error! if type_property.nil?
    
    if type_property["range"].kind_of?(Array)
      raise_error! unless value.kind_of?(Hash)
      
      keys = type_property["range"].collect(&:key)
      value_keys = value.keys
      result = (keys | value_keys) - (keys & value_keys)
      
      raise_error! unless result.length == 0
    elsif type_property["range"].kind_of?(Hash)
      if type_property["range"]["type"] == "/base/ref" || type_property["range"]["type"] == "/base/reverse_ref"
        referenced_entity = collection.find_one({"key" => value, "properties." + type => {"$exists" => true}},
          :fields => ["key", "title"])
        raise_error! if referenced_entity.nil?
        
        value_to_set = {"key" => referenced_entity["key"], "text" => referenced_entity["title"]}
      else
        value_to_set = value
      end
    end
    
    operation = (type_property["unique"] == true) ? "set" : "push"
    property_path = "properties." + type + ".type_properties." + property
    result = collection.update({"key" => entity, property_path => {"$exists" => true}, "$atomic" => true}, 
      {"$" + operation => {property_path + ".value" => value_to_set}}, :safe => true) # TODO: fix to update only if old_value is still value
        
    successful_update? result
  end
  
  def manipulate_property_value(value, options)
    actions = [:add, :edit]
    
    if value.nil? or value = {}
      raise ArgumentError, "value must not be empty"
    end
    
    [:type, :property, :action].each do |field|
      if options[field].nil?
        raise ArgumentError, field + "must not be nil"
      end
    end
    
    unless actions.include?(options[:action])
      raise ArgumentError, ":action must be :add or :edit"
    end
    
    type_definition = Type.collection.find_one({"key" => type, "type_properties.key" => property},
      :fields => ["type_properties.range", "type_properties.unique", "type_properties.key"])
      
    raise_error! if type_definition.nil?
    
    type_property = nil
    type_definition["type_properties"].each do |p|
      if p["key"] == property
        type_property = p
        break
      end
    end
    
    raise_error! if type_property.nil?
    
    if type_property["range"].kind_of?(Array)
      raise_error! unless value.kind_of?(Hash)
      
      keys = type_property["range"].collect(&:key)
      value_keys = value.keys
      result = (keys | value_keys) - (keys & value_keys)
      
      raise_error! unless result.length == 0
    elsif type_property["range"].kind_of?(Hash)
      if type_property["range"]["type"] == "/base/ref" || type_property["range"]["type"] == "/base/reverse_ref"
        referenced_entity = collection.find_one({"key" => value, "properties." + type => {"$exists" => true}},
          :fields => ["key", "title"])
        raise_error! if referenced_entity.nil?
        
        value_to_set = {"key" => referenced_entity["key"], "text" => referenced_entity["title"]}
      else
        value_to_set = value
      end
    end
    
    operation = (type_property["unique"] == true) ? "set" : "push"
    property_path = "properties." + type + ".type_properties." + property
    result = collection.update({"key" => entity, "properties." + type => {"$exists" => true}, "$atomic" => true}, 
      {"$" + operation => {property_path + ".value" => value_to_set}}, :safe => true) # TODO: fix to update only if old_value is still value
    successful_update? result
    if type_property["range"]["type"] == "/base/reverse_ref"
      property_path = "properties." + type_property["range"]["ref_type"] + ".type_properties." + type_property["range"]["property_ref"]
      value_to_set = {"key" => entity, "text" => referenced_entity["title"]}
      result_reference = collection.update({"key" => referenced_entity["key"], "properties." + type_property["range"]["ref_type"] => {"$exists" => true}, "$atomic" => true},
        {"$" + operation => {property_path + ".value" => value_to_set}}, :safe => true)
    end
  end
  
  def self.raise_error!
    raise WrongOperationError, "Wrong operation on the provided property."
  end
  
  def self.successful_update?(result)
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "Entity with the provided criteria was not found."
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