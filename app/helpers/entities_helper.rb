module EntitiesHelper
  def visualize_value(field)
  	return if field.nil?
    if field["type"] != "ref"
      return field["value"]
    elsif !field["key"].nil?
      return if field["key"].length < 1
      link_to field["value"], entity_path(:id => field["key"])
    end
  end
end
