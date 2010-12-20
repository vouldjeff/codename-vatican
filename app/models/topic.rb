class Topic
  include MongoMapper::Document
  
  key :key, String
  key :title, String
  key :description, String
  key :properties, Array
  key :aliases, Array
  key :image, String
  
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :properties
  
  attr_accessible :nil
  
  def self.add_new_type(topic, type) # TODO: could be optimized in the future 
    type_definition = Type.collection.find({"key" => type}, 
      {"name" => 1, "inherits" => 1, "type_properties.key" => 1, "type_properties.label" => 1})
    collection.update({"key" => topic, "properties" => {type.to_s => {"$exist" => false}}, "$atomic" => true}, 
      {"$set" => {"properties" => {type.to_s => type_definition}}})
  end
  
  def self.set_property(topic, type, property, value) # TODO: could be optimized by replacing the unqueness with "safe=true" or "getLastError"
    unless TypeProperty.unqueness?(type, property)
      raise TypePropertyUniqunessOrPresenceError, 
        "The property (#{topic}-#{type}\\#{property}) is not unique (or the document may not even exist)!"
    end
    collection.update({"key" => topic, "properties" => {type.to_s => {property.to_s => {"$exist" => true}}}, "$atomic" => true},
      {"$set" => {"properties" => {type.to_s => {"value" => {property.to_s => value}}}}})
  end
  
  def self.add_property(topic, type, property, value) # TODO: could be optimized by replacing the unqueness with "safe=true" or "getLastError"
    unless TypeProperty.unqueness?(type, property, false)
      raise TypePropertyUniqunessOrPresenceError, 
        "The property (#{topic}-#{type}\\#{property}) is unique (or the document may not even exist)!"
    end
    collection.update({"key" => topic, "properties" => {type.to_s => {property.to_s => {"$exist" => true}}}, "$atomic" => true},
      {"$push" => {"properties" => {type.to_s => {"value" => {property.to_s => value}}}}})
  end
  
  def self.remove_property(topic, type, property, value) # This methods removes value from array property on index...
    
  end
end