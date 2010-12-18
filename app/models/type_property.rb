class TypeProperty
  include MongoMapper::EmbeddedDocument

  key :label, String
  key :comment, String
  key :range, String # TODO: minimize the scope of Range
    
  validates_presence_of :label
  #validates_presence_of :comment
  validates_presence_of :range
  
  embedded_in :type

  attr_accessible :nil
end