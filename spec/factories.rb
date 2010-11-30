Factory.define :type_definition_property, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "name#{n}" }
  f.description "blah"
  f.type_name PropertyTypes.get_type(String)
  f.is_array false
  f.schema []
end

Factory.define :type_without_associations, :class => Type, :default_strategy => :build do |f|
  f.sequence(:key) { |n| "key#{n}" }
  f.name "Person"
  f.description "blah"
end

Factory.define :type, :parent => :type_without_associations do |f|
  f.after_build { |type| type.type_definition_properties << Factory.build(:type_definition_property) }
end

Factory.define :type_with_ref, :parent => :type do |f|
  f.after_build { |type| type.type_definition_properties << Factory.build(:type_definition_property, :type_name => PropertyTypes.get_type(DocumentRef), :name => "ref") }
end

Factory.define :inner_property, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "name#{n}" }
  f.type_name PropertyTypes.get_type(String)
  f.is_array false
  f.schema []
end

Factory.define :property_without_associations, :class => Property, :default_strategy => :build do |f|
  f.name "Property"
  f.key PropertyTypes.keys.first # TODO: fix
end

Factory.define :property, :parent => :property_without_associations do |f|
  f.after_build { |property| property.inner_properties << Factory.build(:inner_property) }
end

Factory.define :topic_without_associations, :class => Topic do |f|
  f.title "Title"
  f.description "Long description"
  f.sequence(:key) { |n| "key#{n}" }
end

Factory.define :topic, :parent => :topic_without_associations do |f|
  f.after_build { |topic| topic.properties << Factory.build(:property) }
end