class TopicBuilder
  def initialize
    topic = Topic.new
  end
  
  def edit_topic(topic_param)
    topic = topic_param
    return self
  end
  
  def set_key(value)
    topic.key = value
    if Topic.where(:key => value).limit(1).count() == 1
      topic.key += " #{BSON::ObjectId.new.to_s}"
    end
    return self
  end
  
  def set_description(value)
    topic.description = value
    return self
  end
  
  def set_name(value)
    topic.name = value
    return self
  end
  
  def add_new_type(value)
    topic.add_new_type(value)
    return self
  end
  
  def find_value_obj(property, inner_property)
    inner_property_obj = topic.properties.find { |p| p.key == property }.find { |p| p.name == inner_property }
    if inner_property_obj.nil?
      raise ArgumentError, "property #{property} with #{inner_property} inner_property was not found"
    end
    return inner_property_obj
  end
  
  def set_or_add_value(property, inner_property, value)
    inner_property_obj = find_value_obj(property, inner_property)
    
    if inner_property_obj.is_array
      inner_property_obj.value << value
    else
      inner_property_obj = value
    end
    return self
  end
  
  def remove_value_at(property, inner_property, position)
    inner_property_obj = find_value_obj(property, inner_property)
    inner_property_obj.delete_at(position) # here might raise Error
    return self
  end
  
  def build()
    topic
  end
end