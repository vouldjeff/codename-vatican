class Property
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :key, String
  
  validates_presence_of :name
  validates_presence_of :key
  validates_presence_of :inner_properties
  
  validates_associated :inner_properties
  
  embedded_in :topic
  many :inner_properties
  
  attr_accessible :nil
  
  def self.initialize_from_type(instance_of, topic)
    property = Property.new
    if instance_of.nil? or !instance_of.is_a?(String)
      raise ArgumentError, "A proper type name in String was expected"
    end
    
    type = Type.where(:key => instance_of).limit(1).first
    
    if type.nil?
      raise UnknownTypeError, "Type with #{instance_of} key was not found"
    end
    
    property.key = instance_of
    property.name = type.name
    
    type.type_definition_properties.each do |definition|
      property.add_new_inner_property(definition)
    end
    
    topic.properties << property
    if type.inherits.size > 0
      parent_types = Type.where(:_id.in => type.inherits).only(:key)
      parent_types.each do |t|
        property.topic.add_new_type(t.key)
      end
    end
    return property
  end
  
  def add_new_inner_property(definition)
    inner_properties << definition.build_inner_property
  end
  
  private
end