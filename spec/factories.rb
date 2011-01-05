Factory.define :type_property, :default_strategy => :build do |f|
  f.sequence(:label) { |n| "name-#{n}" }
  f.sequence(:key) { |n| "key-#{n}" }
  f.comment "blah"
  f.range "RDF::URI"
end

Factory.define :type_without_associations, :class => Type, :default_strategy => :build do |f|
  f.sequence(:key) { |n| "key-#{n}" }
  f.name "Person"
  f.comment "blah"
  f.namespace "type"
end

Factory.define :type, :parent => :type_without_associations do |f|
  f.after_build { |type| type.type_properties << Factory.build(:type_property) }
end

Factory.define :entity, :class => Entity do |f|
  f.sequence(:key) { |n| "key-#{n}" }
  f.title "Title"
  f.description "Long description"
  f.properties Hash["test", true]
  f.namespace "test"
end