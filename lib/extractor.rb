class Extractor
  
  def self.process_value(value, property)
    if property.expected_type == "/type/datetime"
      {"value" => value, "date" => true} 
    elsif value.kind_of? Ken::Resource
      ref = Entity.new
      ref.namespace = property.expected_type.split('/')[1]
      ref.title = value.name
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
  
  def self.by_name(name, namespace = "unknown")
    result = Ken.all(:name => name, :limit => 1)
    return nil if result.length == 0
    @resource = Ken::Topic.get result[0].id
    return nil if @resource.nil?
    
    @entity = Entity.new
    @entity.namespace = namespace
    @entity.title = @resource.name
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
      type["name"] = view.type.name
      type["type_properties"] = []
      
      view.attributes.each do |attribute|
        p = {"key" => attribute.property.id, "label" => attribute.property.name}
        
        if attribute.property.unique?
          p["values"] = process_value(attribute.values.first, attribute.property)
        else
          p["values"] = []
          attribute.values.each do |v|
            p["values"] << process_value(v, attribute.property)
          end
        end
        type["type_properties"] << p
      end
    end
    
    @entity.is_ok = true
    @entity.save!
  end
end