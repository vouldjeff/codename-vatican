class Type
  include MongoMapper::Document

  key :key, String, :required => true
  key :namespace, String, :required => true
  key :name, String, :required => true
  key :comment, String
  key :inherits, Array, :default => []
  key :instances, Integer, :default => 0
  key :is_ok, Boolean, :default => false
  
  many :type_properties
  validates_associated :type_properties
  
  validates_presence_of :key
  validates_uniqueness_of :key, :allow_nil => false
  
  before_validation :create_key, :on => :create
  
  attr_accessible :nil
  
  def self.one_by_key(namespace, key, no_schema = false)
    response = where(:key => "/" + namespace + "/" + key).limit(1)
    if no_schema
      response = response.only(:name, :comment, :key)
    end
    response = response.first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def self.get_skeleton(type) # TODO: rewrite this method, because this would not work with the stuff implemented so far.... Pfff
    skeleton = collection.find_one({"key" => type}, 
      :fields => ["name", "inherits", "type_properties.label", "type_properties.key", "type_properties.values"])
    raise UpdateError, "The type provided was not found." if type.nil?
    
    skeleton
  end
  
  def <<(type_property)
    raise ArgumentError, "TypeProperty not given" unless type_property.kind_of?(TypeProperty)
    type_property.generate_key(self)
    raise ArgumentError, "Type property alredy exists" if type_properties.collect(&:key).include?(type_property.key)
    raise ArgumentError, "TypeProperty is not valid" unless type_property.valid?
    
    type_properties << type_property
  end
  
  private
  def create_key
    raise UpdateError, "Type namespace must not be nil" if namespace.nil?
    raise UpdateError, "Type name must not be nil" if name.nil?
    
    if key.nil?
      self.key = "/" + namespace + "/" + KeyGenerator.generate_from_string(name) 
    end
  end
end