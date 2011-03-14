class TypeProperty
  include MongoMapper::EmbeddedDocument

  key :key, String, :required => true
  key :label, String, :required => true
  key :comment, String
  key :unique, Boolean, :default => false
  key :mediator, Boolean, :default => false
  key :expected_type
  key :values, Hash, :default => {}
  
  validates_presence_of :expected_type
  
  embedded_in :type
  
  before_validation :generate_key, :on => :create
  before_create lambda { value = [] unless unique }

  attr_accessible :nil

  def generate_key(type_obj = nil)
    return if label.nil?
    
    if key.nil?
      self.key = KeyGenerator.generate_from_string(label)
      unless type_obj.type_properties.index{|p| p.key == self.key }.nil?
        self.key = key + "-" + Time.now.to_i.to_s 
      end 
    end
  end
end