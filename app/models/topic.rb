class Topic
  include MongoMapper::Document
  
  key :key, String
  key :title, String
  key :description, String
  key :properties, Hash
  key :aliases, Array
  key :image, String
  
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :properties
  
  attr_accessible :nil
  
  def self.add_new_type(topic, type)
    type_definition = Type.collection.find_one({"key" => type}, 
      :fields => ["name", "inherits", "type_properties.key", "type_properties.label"])
    if type_definition.nil?
      raise ResourceNotFoundError, "The type provided (#{type}) was not found."
    end  
    
    collection.update({"key" => topic, "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      {"$set" => {"properties" => {type => type_definition}}}, :safe => true)
      
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "The topic (#{topic}) was not found."
    end
  end
  
  def self.set_unique_property(topic, type, property, value)
    unless TypeProperty.uniqueness?(type, property)
      raise TypePropertyUniquenessOrPresenceError, 
        "The property (#{topic}-#{type}\\#{property}) is not unique (or it may not even exist)."
    end
    
    property_path = "properties." + type + "." + property
    result = collection.update({"key" => topic, property_path => {"$exists" => true}, "$atomic" => true},
      {"$set" => {property_path => {"value" => value}}}, :safe => true)
      
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "The property (#{topic}-#{type}\\#{property}) does not exist (or the topic itself)."
    end
  end
  
  def self.add_value_to_non_unique_property(topic, type, property, value)
    unless TypeProperty.uniqueness?(type, property, false)
      raise TypePropertyUniquenessOrPresenceError, 
        "The property (#{topic}-#{type}\\#{property}) is unique (or it may not even exist)."
    end
    
    property_path = "properties." + type + "." + property
    begin
      result = collection.update({"key" => topic, property_path => {"$exists" => true}, "$atomic" => true}, 
        {"$push" => {property_path + ".value" => value}}, :safe => true)
    rescue Mongo::OperationFailure
      raise TypePropertyUniquenessOrPresenceError, 
        "The property (#{topic}-#{type}\\#{property}) is unique."
    end
        
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "The property (#{topic}-#{type}\\#{property}) does not exist (or the topic itself)."
    end
  end
  
  def self.remove_non_unique_property_at_position(topic, type, property, position)
    # TODO: write
  end
end