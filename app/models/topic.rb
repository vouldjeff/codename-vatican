class Topic
  include MongoMapper::Document
  
  key :key, String
  key :title, String
  key :description, String
  key :image, String
  key :aliases, Array
  key :instance_of, Array
  
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :properties
  
  validates_associated :properties
  validates_associated :callbacks
  validates_associated :ids
  
  many :properties
  many :ids
  many :callbacks
  
  before_save :update_instance_of
  
  attr_accessible :nil
  
  def add_new_type(type_name)
    if instance_of.include?(type_name)
      raise ArgumentError, "#{type_name} is already implemented in this topic"
    end
    properties << Property.initialize_from_type(type_name, self)
  end
  
  private
  def update_instance_of
    instance_of = []
    
    properties.each do |property|
      if property.nil?
        next
      end
      instance_of << property.key
    end
  end
end