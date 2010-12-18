class Topic
  include MongoMapper::Document
  
  key :key, String
  key :title, String
  key :description, String
  key :properties, Array
  key :aliases, Array
  key :image, String
  
  validates_presence_of :key
  validates_uniqueness_of :key
  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :properties
  
  attr_accessible :nil
end