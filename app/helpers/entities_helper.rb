module EntitiesHelper
  def visualize_value(field)
  	return if field.nil?
    if field["key"].nil?
      return field["value"]
    else
      link_to field["value"], entity_path(:id => field["key"])
    end
  end
end
