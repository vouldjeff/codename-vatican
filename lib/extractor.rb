class Extractor  
  ToLang.start(APP_CONFIG.google_maps_api)
  
  # Initializes the extraction proccess itself
  def run(opts = {})
    opts[:translate] ||= false
    
    search = Entity.where(:freebase => @resource.id).first
    @old_entity = !search.nil?
    @entity = search || Entity.new
    
    unless @entity.is_ok?
      if @entity.key.nil?
        # Set unique key
        @entity.key = (@resource.id.split("/")[1] == "en") ? @resource.id.split("/").last.tr("_", "-") : nil
        unless Entity.collection.find_one({:key => @entity.key}, :fields => [:key]).nil?
          @entity.key = @entity.key + "-" + Time.now.to_i.to_s
        end
        @entity.title = (opts[:translate]) ? @resource.name.to_bulgarian_from_english : @resource.name
      end
      
      {:description= => :description, :aliases= => :aliases, 
        :image= => :thumbnail, :freebase= => :id, :same_as= => :webpages}.each do |to, from|
        @entity.send(to, @resource.send(from))
      end
      raise ExtractError, [:first_save_invalid, @entity.errors] unless @entity.save
    end
    
    @resource.views.each do |view|
      next if view.type.id == "/common/topic"
      
      type_search = Type.where(:freebase => view.type.id).first
      type_obj = type_search || Type.new
      
      unless type_obj.is_ok?
        type_obj.namespace = view.type.id.split("/")[1].tr("_", "-")
        
        # Create Namespace if it does not exist
        begin
          namespace = Namespace.one_by_key(type_obj.namespace)
        rescue MongoMapper::DocumentNotFound => e
          namespace = Namespace.new 
          namespace.key = type_obj.namespace
          namespace.name = (opts[:translate]) ? type_obj.namespace.capitalize.tr("_", " ").to_bulgarian_from_english : type_obj.namespace.capitalize.tr("_", " ")
          raise ExtractError, [:namespace_save_invalid, namespace.errors] unless namespace.save
        end
        
        if type_obj.key.nil?
          # Set unique type_obj.key
          type_obj.key = view.type.id.split("/").last.tr("_", "-")
          unless Type.collection.find_one({:namespace => type_obj.namespace, :key => type_obj.key}, :fields => [:key]).nil?
            type_obj.key = type_obj.key + "-" + Time.now.to_i.to_s
          end
        end
          
        type_obj.name = (opts[:translate]) ? view.type.name.to_bulgarian_from_english : view.type.name
        type_obj.to_bg = opts[:translate]
        type_obj.freebase = view.type.id
        type_obj.is_ok = true
        
        raise ExtractError, [:first_type_save_invalid, type_obj.errors] unless type_obj.save
        add_type(type_obj)
      end
      
      type_obj.instances += 1 if @entity.properties[type_obj.full_key].nil?
      @entity.properties[type_obj.full_key] ||= {}
      type = @entity.properties[type_obj.full_key]
      type["name"] = type_obj.name
      type["type_properties"] ||= []
      
      view.attributes.each do |attribute|
        next unless type["type_properties"].index{|p| p["key"] == attribute.property.id.split("/").last}.nil?
        
        property_index = type_obj.type_properties.index{|p| p.key == attribute.property.id.split("/").last}
        if property_index.nil?
          property_obj = TypeProperty.new
          property_obj.key = attribute.property.id.split("/").last
          property_obj.label = (opts[:translate]) ? attribute.property.name.to_bulgarian_from_english : attribute.property.name 
          property_obj.unique = (attribute.property.unique? && attribute.values.count == 1)
          property_obj.expected_type = attribute.property.expected_type
          
          unless type_obj.type_properties.index{|p| p.key == property_obj.key }.nil?
            property_obj.key += "-" + Time.now.to_i.to_s 
          end 
          type_obj << property_obj
          
        else
          property_obj = type_obj.type_properties[property_index]
        end
        
        filled_property = {"key" => property_obj.key, "label" => property_obj.label}
        
        if attribute.property.unique? && attribute.values.count == 1
          filled_property["values"] = process_value(attribute.values.first, attribute.property, opts[:translate])
        else
          filled_property["values"] = []
          attribute.values.each do |v|
            filled_property["values"] << process_value(v, attribute.property, opts[:translate])
          end
        end
        type["type_properties"] << filled_property
      end
      raise ExtractError, [:last_type_save_invalid, type_obj.errors] unless type_obj.save
    end
    
    @entity.is_ok = true
    @entity.to_bg = opts[:translate]
    raise ExtractError, [:last_save_invalid, @entity.errors] unless @entity.save
  end
  
  def initialize(name, by_key = false)
    unless by_key
      result = Ken.all(:name => name, :limit => 1)
      raise ExtractError, :entity_not_found if result.length == 0
      key = result[0].id
    else
      key = name
    end
    
    @resource = Ken::Topic.get key
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
    @created_types.each(&:destroy)
    @entity.destroy unless @old_entity
  end
  
  private
  
  # Proccesses a particular type_property
  def process_value(value, property, to_bg = false)  
    if property.expected_type == "/type/datetime"
      time = Chronic.parse(value)
      {"value" => (!time.nil?) ? Date.to_mongo(time.to_date) : nil, "type" => "date"} 
    elsif property.expected_type == "/type/float"
      {"value" => value.to_f}
    elsif property.expected_type == "/type/integer"
      {"value" => value.to_i}
    elsif value.kind_of? Ken::Resource
      search = Entity.where(:key => KeyGenerator.generate_from_string(value.name)).first
      ref = search || Entity.new
      
      ref.title = (to_bg) ? value.name.to_bulgarian_from_english : value.name
      ref.freebase = value.id
      if ref.save
        add_entity(ref) if search.nil?
        {"key" => ref.key, "value" => ref.title, "type" => "ref"}
      else
        raise ExtractError, [:ref_save_invalid, ref.errors]
      end
    else
      { "value" => value }
    end
  end
  
  def add_entity(entity)
    @created_entities << entity
  end
  
  def add_type(type)
    @created_types << type
  end
end