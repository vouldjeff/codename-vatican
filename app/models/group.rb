class Group
  include MongoMapper::Document
  
  key :key, String, :required => true
  key :name, String, :required => true
  
  validates_uniqueness_of :key
  before_validation :create_key, :on => :create
  
  def self.one_by_key(key)
    response = where(:key => key).limit(1).first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def to_param
    key
  end
  
  private
  def create_key
    if key.nil?
      self.key = KeyGenerator.generate_from_string(name) 
    end
  end
end