class Extractor  
  ToLang.start("AIzaSyC_5o2n6KuvAzPrQzQ5DAwpmRuyqKoNR8k")
  
  def process_value(value, property, to_bg = false)  
    if property.expected_type == "/type/datetime"
      {"value" => value, "date" => true} 
    elsif value.kind_of? Ken::Resource
      
      search = Entity.where(:key => KeyGenerator.generate_from_string(value.name)).first
      ref = search || Entity.new
      
      ref.title = (to_bg) ? value.name.to_bulgarian_from_english : value.name
      ref.freebase = value.id
      if ref.save
        add_entity(ref) if search.nil?
        {"key" => ref.key, "value" => ref.title}
      else
        raise ExtractError, [:ref_save_invalid, ref.errors]
      end
    else
      { "value" => value }
    end
  end
  
  def run(opts = {})
    opts[:translate] ||= false
    
    search = Entity.where(:key => KeyGenerator.generate_from_string(@resource.name)).first
    @old_entity = !search.nil?
    @entity = search || Entity.new
    
    @entity.title = (opts[:translate]) ? @resource.name.to_bulgarian_from_english : @resource.name
    raise ExtractError, [:first_save_invalid, @entity.errors] unless @entity.save
      
    {:description= => :description, :aliases= => :aliases, 
      :image= => :thumbnail, :freebase= => :url, :same_as= => :webpages}.each do |to, from|
      @entity.send(to, @resource.send(from))
    end
    
    @resource.views.each do |view|
      next if view.name == "/common/topic"
      
      @entity.properties[view.type.id] ||= {}
      type = @entity.properties[view.type.id]
      type["name"] = (opts[:translate]) ? view.type.name.to_bulgarian_from_english : view.type.name
      type["type_properties"] ||= []
      
      view.attributes.each do |attribute|
        p = {"key" => attribute.property.id, "label" => (opts[:translate]) ? attribute.property.name.to_bulgarian_from_english : attribute.property.name}
        
        if attribute.property.unique?
          p["values"] = process_value(attribute.values.first, attribute.property, opts[:translate])
        else
          p["values"] = []
          attribute.values.each do |v|
            p["values"] << process_value(v, attribute.property, opts[:translate])
          end
        end
        type["type_properties"] << p
      end
    end
    
    @entity.is_ok = true
    @entity.to_bg = true if opts[:translate]
    raise ExtractError, [:last_save_invalid, @entity.errors] unless @entity.save
  end
  
  def initialize(name)
    result = Ken.all(:name => name, :limit => 1)
    raise ExtractError, :entity_not_found if result.length == 0
    @resource = Ken::Topic.get result[0].id
    raise ExtractError, :resource_not_found if @resource.nil?
    
    @created_entities = []
    @created_types = []
    @old_entity = false
  end
  
  def result
    @entity.key
  end
  
  def rollback()
    @created_entities.each(&:destroy)
    @entity.destroy unless @old_entity
  end
  
  def add_entity(entity)
    @created_entities << entity
  end
  
  def add_type(type)
    @created_types << type
  end
end
