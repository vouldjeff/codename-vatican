class Entity
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Timestamps
  timestamps!
  
  key :key, String, :required => true
  key :revision, Integer, :default => 1, :required => true
  key :title, String, :required => true
  key :description, String
  key :properties, Hash, :default => {}
  key :aliases, Array, :default => []
  key :image, String
  key :same_as, Array, :default => []
  
  key :to_bg, Boolean, :default => false
  key :is_ok, Boolean, :default => false
  key :checked, Boolean, :default => false
  
  key :freebase, String
  
  before_validation :create_key, :on => :create
  before_save :save_referenced
  
  validates_uniqueness_of :key, :allow_nil => false
  
  attr_accessible :title, :description, :image, :aliases_string, :checked
  
  def self.one_by_key(key)
    response = where(:key => key).limit(1).first
    raise MongoMapper::DocumentNotFound if response.nil?
    
    response
  end
  
  def to_triples
    triples = RdfTriplesBuilder.new APP_CONFIG.domain + key
    
    {"title" => title, "description" => description, "date" => last_edited, "identifier" => key}.each do |k, v|
      triples.add("http://purl.org/dc/elements/1.1/" + k, v)
    end
    
    same_as.each do |s|
      triples.add("http://www.w3.org/2002/07/owl#sameAs", s["url"])
    end
    
    properties.each do |type_key, type|
      type["type_properties"].each do |property|
        unless property["values"].kind_of? Array
          triples.add(property["key"], property["values"], :bp => APP_CONFIG.domain, :br => APP_CONFIG.domain)
        else
          property["values"].each do |property_parent|
            triples.add(property["key"], property_parent, :bp => APP_CONFIG.domain, :br => APP_CONFIG.domain)
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
 
  def manipulate_property_value(value, options) # finish implementation 
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
  
  def to_param
    key
  end

  def aliases_string
    self.aliases.join(", ")
  end
  
  def aliases_string=(value)
    self.aliases = value.split(", ")
  end
  
  private
  def create_key
    return if title.nil?
    
    if key.nil?
      self.key = KeyGenerator.generate_from_string(title) 
      unless collection.find_one({:key => key}, :fields => [:key]).nil?
        self.key = key + "-" + Time.now.to_i.to_s 
      end
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
