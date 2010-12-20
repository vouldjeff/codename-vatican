class TypeProperty
  include MongoMapper::EmbeddedDocument

  key :key, String
  key :label, String
  key :comment, String
  key :range, String # TODO: minimize the scope of Range
  key :unique, Boolean, :default => false
  key :disambiguating, Boolean, :default => false
    
  validates_presence_of :label
  #validates_presence_of :comment
  validates_presence_of :range
  validates_presence_of :key
  #validates_uniqueness_of :key # This should be rewritten...
  
  before_create :generate_key
  
  embedded_in :type

  attr_accessible :nil
  
  # if returns false, the document may not even exist
  def self.uniqueness?(type, property, is_unique = true)
    Type.collection.find({"key" => type, "properties" => {property.to_s => {"unique" => is_unique}}}).count == 1
  end
  
  def uniqueness?
    unqiue
  end
      
  private
  def generate_key
    if key.nil?
      key = type.key + label.downcase.gsub(/[^a-z ]/, "").tr(" ", "-")
    end
  end
end