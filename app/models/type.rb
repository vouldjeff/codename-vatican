class Type
  include MongoMapper::Document

  key :key, String
  key :namespace, String
  key :name, String
  key :comment, String
  key :inherits, Array
  
  many :type_properties
  
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :namespace
  validates_presence_of :name
  validates_presence_of :comment
  validates_associated :type_properties
  
  before_create :create_key
  
  attr_accessible :nil
  
  private
  def create_key
    if key.nil?
      key = "/" + namespace + "/" + name.downcase.gsub(/[^a-z ]/, "").tr(" ", "-") 
    end
  end
end