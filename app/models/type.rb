class Type
  include MongoMapper::Document

  key :key, String
  key :namespace, String, :required => true
  key :name, String, :required => true
  key :comment, String, :required => true
  key :inherits, Array
  
  many :type_properties
  validates_associated :type_properties
  
  validates_presence_of :key
  validates_uniqueness_of :key, :allow_nil => false
  
  before_validation :create_key, :on => :create
  
  attr_accessible :nil
  
  def self.get_skeleton(type) # TODO: rewrite this method, because this would not work with the stuff implemented so far.... Pfff
    type = collection.find_one({"key" => type}, 
      :fields => ["name", "inherits", "type_properties.key", "type_properties.label", "type_properties.range"])
    if type.nil?
      raise ResourceNotFoundError, "The type provided was not found."
    end
    
    skeleton
  end
  
  def add_new_type_property(label, range, unique = false, comment = "")
    errors.add :base, "Type property alredy exists" if type_properties.collect{|p| p.label}.include?(label)
    property = TypeProperty.new(:label => label, :range => range, :unique => unique, :comment => comment)
    type_properties << property
  end
  
  private
  def create_key
    if key.nil? and !namespace.nil? and !name.nil?
      self.key = "/" + namespace + "/" + KeyGenerator.generate_from_string(name) 
    end
  end
end