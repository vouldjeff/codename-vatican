class Type
  include MongoMapper::Document

  key :key, String, :required => true, :unique => true
  key :namespace, String, :required => true
  key :name, String, :required => true
  key :comment, String, :required => true
  key :inherits, Array
  
  many :type_properties
  validates_associated :type_properties
  
  before_validation_on_create :create_key
  
  attr_accessible :nil
  
  def self.get_skeleton(type)
    type = collection.find_one({"key" => type}, 
      :fields => ["name", "inherits", "type_properties.key", "type_properties.label"])
    if type.nil?
      raise ResourceNotFoundError, "The type provided was not found."
    end
    
    skeleton = {"name" => type["name"], "inherits" => type["inherits"]}
    type["type_properties"].each do |property|
      skeleton[property["key"]] = {"label" => property["label"], "range" => property["range"]}
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