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
  
  # TODO: write specs for this test with "code coverege"
  def self.add_new_type(topic, type)
    type_skeleton = Type.get_skeleton(type)  
    
    collection.update({"key" => topic, "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      {"$set" => {"properties" => {type => type_skeleton}}}, :safe => true)
      
    successful_update? result
  end
  
  # TODO: write specs for this test with "code coverege"
  def self.set_unique_property(topic, type, property, value)
    valid_operation_on? type, property, :set
    
    property_path = "properties." + type + "." + property
    result = collection.update({"key" => topic, property_path => {"$exists" => true}, "$atomic" => true},
      {"$set" => {property_path => {"value" => value}}}, :safe => true)
      
    successful_update? result
  end
  
  # TODO: write specs for this test with "code coverege"
  def self.add_value_to_non_unique_property(topic, type, property, value)
    valid_operation_on? type, property, :push
    
    property_path = "properties." + type + "." + property
    begin
      result = collection.update({"key" => topic, property_path => {"$exists" => true}, "$atomic" => true}, 
        {"$push" => {property_path + ".value" => value}}, :safe => true)
    rescue Mongo::OperationFailure
      raise TypePropertyUniquenessOrPresenceError, 
        "Wrong operation on the provided property."
    end
        
    successful_update? result
  end
  
  def self.successful_update?(result)
    unless result[0][0]["updatedExisting"]
      raise ResourceNotFoundError, "Topic with the provided criteria was not found."
    end
  end
  
  def self.valid_operation_on?(type, property, operation = :set)
    unique = (operation == :set) ? true : false
    unless TypeProperty.uniqueness?(type, property, unique)
      raise TypePropertyUniquenessOrPresenceError, 
        "Wrong operation on the provided property."
    end
  end
  
  def self.remove_non_unique_property_at_position(topic, type, property, position)
    # TODO: write
  end
end