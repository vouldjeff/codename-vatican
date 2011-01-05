class TypeProperty
  include MongoMapper::EmbeddedDocument

  key :key, String, :required => true
  key :label, String, :required => true
  key :comment, String
  key :range, :required => true
  key :unique, Boolean, :default => false
  
  before_validation :create_key, :on => :create
  
  embedded_in :type

  attr_accessible :nil
  
  private  
  def create_key
    if key.nil? and !label.nil? and !type.nil?
      self.key = type.key + "/" + KeyGenerator.generate_from_string(label)
    end
  end
end