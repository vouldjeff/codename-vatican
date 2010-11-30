class DocumentRef
  attr_reader :type, :referenced_type, :referenced_property, :url, :text
  attr_writer :type, :referenced_type, :referenced_property, :url, :text
  
  def self.build(type_param, referenced_type_param, referenced_property_param)
    if type_param.nil?
      raise ArgumentError, "type_param must not be nil"
    end
    
    type_obj = Type.collection.find("key" => type_param, :fields => {"_id" => 1})
    if type_obj.nil?
      raise UnknownTypeError, "-#{type_param}- type was not found"
    end
    
    obj = DocumentRef.new
    obj.type = type_param
    
    ref_type_obj = Type.collection.find_one("key" => referenced_type_param, "type_definition_properties" => { "$elemMatch" => { "name" => referenced_property_param, "type_name" => PropertyTypes.get_type(DocumentRef)}})
    if ref_type_obj.nil?
      raise UnknownTypeError, "-#{referenced_type_param}- type with -#{referenced_property_param}- definition_property whose type is DocumentRef was not found"
    end
    
    obj.referenced_type = referenced_type_param
    obj.referenced_property = referenced_property_param
    
    obj
  end
    
  def initialize(value = nil)
     unless value.nil?
       @url = value["url"]
       @text = value["text"]
     end
  end 
  
  def get_schema
    { "type" => @type, "referenced_type" => @referenced_type, "referenced_property" => @referenced_property }
  end
  
  def to_s
    "<a href=\"#{@url}\">#{text}</a>" # TODO: fix
  end
  
  def self.to_mongo(instance)
    
  end
  
  def self.from_mongo(value)
    
  end
end