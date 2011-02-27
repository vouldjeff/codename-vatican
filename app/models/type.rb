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
  
  before_validation :create_key, :on => :create
  validate :check_unique
  
  attr_accessible :nil
  
  def self.one_by_key(namespace, key, no_schema = false)
    response = where(:namespace => namespace, :key => key).limit(1)
    if no_schema
      response = response.only(:name, :comment, :namespace, :key)
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
  
  def to_param
    key
  end
  
  private
  def create_key
    return if namespace.nil?
    return if name.nil?
    
    if key.nil?
      self.key = KeyGenerator.generate_from_string(name)
      unless collection.find_one({:key => key}, :fields => [:key]).nil?
        self.key = key + "-" + Time.now.to_i.to_s 
      end 
    end
  end
  
  def check_unique
    doc_count = Type.where(:namespace => namespace).where(:key => key).where(:_id.ne => _id).count
    
    if doc_count > 0
      errors.add_to_base "The key is not unique in the scope of namespace."
    end
  end
end