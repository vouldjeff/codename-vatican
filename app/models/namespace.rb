class Namespace
  include MongoMapper::Document
  
  key :key, String, :required => true
  key :description, String, :required => true
  
  validates_uniqueness_of :key
  before_validation :check_key_format
  
  private
  def check_key_format
    unless key.nil?
      self.key = KeyGenerator.generate_from_string(key) 
    end
  end
end