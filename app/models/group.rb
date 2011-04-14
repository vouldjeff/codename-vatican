class Group
  include MongoMapper::Document
  
  key :key, String, :required => true
  key :name, String, :required => true
  
  validates_uniqueness_of :key
  before_validation :check_key_format
  
  def self.one_by_key(key)
    response = where(:key => key).limit(1).first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def to_param
    key
  end
  
  private
  def check_key_format
    unless key.nil?
      self.key = KeyGenerator.generate_from_string(key) 
    end
  end
end