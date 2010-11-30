class InnerProperty
  include MongoMapper::EmbeddedDocument
  
  key :name, String
  key :type_name, String
  key :schema
  key :value
  key :is_array, Boolean, :default => false
  
  validates_presence_of :name
  validates_presence_of :type_name
  validates_inclusion_of :type_name, :in => PropertyTypes.keys
  
  validate :proper_data_type
  before_validation :type_cast
  
  embedded_in :property
  
  attr_accessible :nil
  
  private
  
  def type_cast # TODO: rewrite
    if value.nil?
      return
    end
    
    if value.is_a?(String)
      if type_name == "/base/integer"
        value = value.to_i 
      elsif type_name == "/base/float"
        value = value.to_f
      end
    end
  end
  
  def proper_data_type
    if value.nil?
      return
    end
    errors.add_to_base("The type of the value given does not match the type...") unless value.is_a?(PropertyTypes[type_name])
  end
end