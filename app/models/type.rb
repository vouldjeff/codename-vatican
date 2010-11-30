class Type
  include MongoMapper::Document

  key :key, String
  key :name, String
  key :description, String
  key :inherits, Array, :typecast => 'ObjectId' # TODO: change if _id type is changed
  
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :key
  validates_uniqueness_of :key
  
  validates_associated :type_definition_properties
  
  attr_accessible :nil
  
  many :type_definition_properties
  
  def add_new_type_definition_property(name, type_name, is_array = false, schema = nil, description = nil)
    type_definition_property = TypeDefinitionProperty.new
    type_definition_property.name = name
    type_definition_property.type_name = type_name
    type_definition_property.schema = schema
    type_definition_property.is_array = is_array
    type_definition_property.description = description
    type_definition_properties << type_definition_property
  end
  
  def self.is_valid_key?(key_param)
    if where(:key => key_param).limit(1).count() == 1
      return true
    end
    return false
  end
end