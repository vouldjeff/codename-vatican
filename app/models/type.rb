class Type
  include MongoMapper::Document

  key :key, String, :required => true
  key :namespace, String, :required => true
  key :name, String, :required => true
  key :comment, String
  key :inherits, Array, :default => []
  key :instances, Integer, :default => 0

  key :to_bg, Boolean, :default => false
  key :is_ok, Boolean, :default => false
  key :checked, Boolean, :default => false
  
  key :freebase, String
  
  many :type_properties
  validates_associated :type_properties
  
  before_validation :create_key, :on => :create
  validate :check_unique
  
  attr_accessible :nil
  
  def self.one_by_key(namespace, key, only = nil)
    response = where(:namespace => namespace, :key => key).limit(1)
    response = response.only(:name, :comment, :namespace, :key, "type_properties.label".to_sym, "type_properties.key", "type_properties.expected_type", "type_properties.mediator")
    response = response.first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def <<(type_property)
    raise ArgumentError, "TypeProperty not given" unless type_property.kind_of?(TypeProperty)
    type_property.generate_key
    raise ArgumentError, "Type property alredy exists" unless type_properties.index{|p| p.key == type_property.key}.nil?
    raise ArgumentError, "TypeProperty is not valid" unless type_property.valid?
    
    type_properties << type_property
  end
  
  def to_param
    key
  end
  
  def full_key
    namespace + "/" + key
  end
  
  private
  def create_key
    return if namespace.nil?
    return if name.nil?
    
    if key.nil?
      self.key = KeyGenerator.generate_from_string(name)
      unless collection.find_one({:namespace => namespace, :key => key}, :fields => [:key]).nil?
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