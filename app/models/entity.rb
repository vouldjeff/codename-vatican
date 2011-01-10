class Entity
  include MongoMapper::Document
  
  key :key, String
  key :namespace, String, :required => true
  key :title, String, :required => true
  key :description, String, :required => true
  key :properties, Hash
  key :aliases, Array
  key :image, String
  
  before_validation :create_key, :on => :create
  before_save :save_referenced
  
  validates_presence_of :key
  validates_uniqueness_of :key, :allow_nil => false
  
  attr_accessible :nil
  
  def self.one_by_key(namespace, key) 
    response = where(:key => "/" + namespace + "/" + key).limit(1).first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def self.with_type(namespace, key, options = {}) 
    response = where("properties./" + namespace + "/" + key => {"$exists" => true}).limit(options[:limit] || 20).sort(:title)
    response = response.skip(options[:skip]) unless options[:skip].nil?
    response = response.sort(options[:sort]) unless options[:sort].nil?
    
    response
  end
  
  def to_triples
    triples = RdfTriplesBuilder.new key # TODO: fix to append domain name
    
    properties.each do |type_key, type|
      type["type_properties"].each do |property|
        unless property["values"].kind_of? Array
          triples.add(property["key"], property["values"]) # TODO: append type view url
        else
          property["values"].each do |property_parent|
            triples.add(property["key"], property_parent) # TODO: append type view url
          end
        end
      end
    end
    
    triples.to_a
  end
  
  def self.add_new_type(entity, type)
    type_skeleton = Type.get_skeleton(type)  
    unless type_skeleton["inherits"].nil?
      type_skeleton["inherits"].each do |parent|
        add_new_type(entity, parent)
      end
    end
    type_skeleton.delete("inherits")
    
    result = collection.update({"key" => entity, "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      {"$set" => {"properties." + type => type_skeleton}}, :safe => true)
      
    successful_update? result
  end
 
  def manipulate_property_value(value, options)    
    raise ArgumentError, "value must not be empty" if value.nil?
    raise ArgumentError, ":action must be :add or :edit" unless [:add, :edit].include?(options[:action])
    [:type, :property].each do |field|
      raise ArgumentError, field.to_s + " must not be nil" if options[field].nil?
    end
    
    property_key = options[:type] + "/" + options[:properties]
    type_property = nil
    properties[options[:type]]["type_properties"].each do |p|
      if p["key"].eql?(property_key)
        type_property = p
        break
      end
    end
    
    case type_property["range"]["type"]
      when "/base/ref", "/base/reverse_ref"
        referenced_entity = collection.find_one({"key" => value, "properties." + options[:type] => {"$exists" => true}},
          :fields => ["key", "title"])
        Entity.raise_error!("Referenced Entity was not found") if referenced_entity.nil?
        
        value_to_set = {"key" => referenced_entity["key"], "value" => referenced_entity["title"]}
      else
        value_to_set = {"value" => value.to_s}
    end
    
    if type_property["unique"]
      type_property["values"] = value_to_set
    else
      type_property["values"] = [] unless type_property["values"].kind_of? Array
      type_property["values"] << value_to_set
    end
    
    if type_property["range"]["type"] == "/base/reverse_ref"
      @references = {} if @references.nil?
      
    end
  end
  
  def self.raise_error!(message = "Wrong operation on the provided property.")
    raise UpdateError, message
  end
  
  def self.successful_update?(result)
    unless result[0][0]["updatedExisting"]
      raise UpdateError, "Entity with the provided criteria was not found."
    end
  end
  
  def self.remove_non_unique_property_at_position(entity, type, property, position)
    # TODO: write
  end
  
  private
  def create_key
    raise UpdateError, "Entity namespace must not be nil" if namespace.nil?
    raise UpdateError, "Entity title must not be nil" if title.nil?
    
    if key.nil?
      self.key = "/" + namespace + "/" + KeyGenerator.generate_from_string(title) 
    end
  end

  def save_referenced
    return if @references.nil?
    
    @references.each do |ref|
      #collection.update({"key" => ref[0], "properties." + type => {"$exists" => false}, "$atomic" => true}, 
      #  {"$set" => {"properties." + type => type_skeleton}})
    end
  end
end