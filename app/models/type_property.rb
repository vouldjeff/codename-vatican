class TypeProperty
  include MongoMapper::EmbeddedDocument

  key :key, String, :required => true
  key :label, String, :required => true
  key :comment, String
  key :range, :default => {:type => "/base/text"}, :required => true
  key :unique, Boolean, :default => false
  key :values, Hash, :default => {}
  
  embedded_in :type
  
  before_create lambda { value = [] unless unique }

  attr_accessible :nil

  def generate_key(type)
    if type.nil?
      errors.add_to_base "Type must not be nil"
    end
    unless type.valid?
      errors.add_to_base "Type must be valid"
    end
    return if label.nil?
    
    if key.nil?
      self.key = type.key + "/" + KeyGenerator.generate_from_string(label)
      unless type.type_properties.index{|p| p.key == self.key }.nil?
        self.key = key + "-" + Time.now.to_i.to_s 
      end 
    end
  end
end