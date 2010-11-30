class DocumentRef
  attr_reader :type, :refered_type, :refered_property, :url, :text
  attr_writer :url, :text
  
  def self.build(type_param, refered_type_param, refered_property_param)
    @type = type_param
    type_obj = Type.collection.find_one({:key => refered_type_param, "type_definition_properties.name" => refered_property_param})
    if type_obj.nil?
      raise UnknownTypeError, "#{refered_type_param} type with #{refered_property_param} definition_property was not found"
    end
    @refered_type = refered_type_param
    @refered_property = refered_property_param
  end
    
  def initialize(value = nil)
     unless value.nil?
       @url = value["url"]
       @text = value["text"]
     end
  end 
  
  def to_s
    "<a href=\"#{@url}\">#{text}</a>" # TODO: fix
  end
end