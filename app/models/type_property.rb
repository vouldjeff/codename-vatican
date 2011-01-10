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
    raise ArgumentError, "Type must not be nil" if type.nil?
    raise ArgumentError, "Type must be valid" unless type.valid?
    raise UpdateError, "TypeProperty label must not be nil" if label.nil?
    
    if key.nil?
      self.key = type.key + "/" + KeyGenerator.generate_from_string(label)
    end
  end
end