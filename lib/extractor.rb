class Extractor
  ToLang.start("AIzaSyBWoOI7KM0fyI70N_NWn47ieEJ3W084BSs")
  
  def self.process_value(value, property, to_bg = false)
    if property.expected_type == "/type/datetime"
      {"value" => value, "date" => true} 
    elsif value.kind_of? Ken::Resource
      
      search = Entity.where(:key => "/" + KeyGenerator.generate_from_string(value.name)).first
      if search.nil?
        ref = Entity.new
      else
        ref = search
      end
      ref.namespace = property.expected_type.split('/')[1]
      ref.title = (to_bg) ? value.name.to_bulgarian_from_english : value.name
      ref.freebase = value.id
      if ref.save!
        {"key" => ref.key, "value" => ref.title}
      else
        nil
      end
    else
      { "value" => value }
    end
  end
  
  def self.by_name(name, to_bg = false, namespace = "unknown")
    result = Ken.all(:name => name, :limit => 1)
    return nil if result.length == 0
    @resource = Ken::Topic.get result[0].id
    return nil if @resource.nil?
    
    search = Entity.where(:key => "/" + KeyGenerator.generate_from_string(@resource.name)).first
    if search.nil?
      @entity = Entity.new
    else
      @entity = search
    end
    @entity.namespace = namespace
    @entity.title = (to_bg) ? @resource.name.to_bulgarian_from_english : @resource.name
    @entity.save!
    
    @entity.description = @resource.description
    @entity.aliases = @resource.aliases
    @entity.image = @resource.thumbnail
    @entity.freebase = @resource.url
    @entity.same_as = @resource.webpages
    
    @resource.views.each do |view|
      next if view.name == "/common/topic"
      
      @entity.properties[view.type.id] = {}
      type = @entity.properties[view.type.id]
      type["name"] = (to_bg) ? view.type.name.to_bulgarian_from_english : view.type.name
      type["type_properties"] = []
      
      view.attributes.each do |attribute|
        p = {"key" => attribute.property.id, "label" => (to_bg) ? attribute.property.name.to_bulgarian_from_english : attribute.property.name}
        
        if attribute.property.unique?
          p["values"] = process_value(attribute.values.first, attribute.property, to_bg)
        else
          p["values"] = []
          attribute.values.each do |v|
            p["values"] << process_value(v, attribute.property, to_bg)
          end
        end
        type["type_properties"] << p
      end
    end
    
    @entity.is_ok = true
    @entity.to_bg = true if to_bg
    @entity.save!
    
    @entity.key
  end
end