class TypeDefinitionProperty
  include MongoMapper::EmbeddedDocument

  key :name, String
  key :description
  key :type_name, String
  key :schema # If a complex type is used, describe its schema here!!!
  key :is_array, Boolean, :default => false
  
  validates_presence_of :name
  validates_presence_of :type_name
  validates_inclusion_of :type_name, :in => PropertyTypes.keys
  
  attr_accessible :nil
  
  embedded_in :type
  
  def build_inner_property
    inner_property = InnerProperty.new
    inner_property.name = name
    inner_property.type_name = type_name
    inner_property.schema = schema
    inner_property.is_array = is_array
    return inner_property
  end
  
  private
end