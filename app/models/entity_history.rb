class EntityHistory
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Timestamps
  timestamps!
  
  key :revision, String, :default => 1, :required => true
  key :by, String, :required => true
  key :ip, String, :required => true
  key :entity, String, :required => true

  key :added, Array, :default => []
  key :edited, Hash, :default => {}

  LIST = ["_id", "revision", "created_at", "freebase", "updated_at", "key", "to_bg", "last_edited"]

  def self.revert_to(entity_id, history_id)
    point = find(history_id)
    return unless entity_id == point.entity
    changes = where(:entity => point.entity).where(:revision.gt => point.revision).sort(:revision.desc)

    edited = nil
    changes.each do |r|
      if edited.nil?
        edited = r.edited
        next
      end

      edited.merge! r.edited
    end

    unless edited.nil?
      edited.merge! point.edited
    else
      edited = point.edited
    end

    rm = {}
    changes.collect{|c| c.added }.flatten.uniq.each do |e|
      rm[e] = 1
      edited.delete e unless edited.nil?
    end

    edited ||= {}
    edited["revision"] = point.revision
    Entity.collection.update({"key" => point.entity}, {"$unset" => rm, "$set" => edited})
    
    point.destroy
    changes.each(&:destroy)
  end

  def self.track(entity)
    old_entity = Entity.collection.find_one({"key" => entity.key}).dotted.flat
    entity = entity.to_mongo.dotted.flat
    
    version = new

    version.entity = entity["key"]  
    version.revision = entity["revision"].to_i

    old_keys = old_entity.keys
    new_keys = entity.keys

    LIST.each{|k| old_keys.delete k; new_keys.delete k; }

    version.added = new_keys - old_keys
    removed = old_keys - new_keys
    
    removed.each do |key|
      version.edited[key] = old_entity[key]
    end

    (old_keys - removed).each do |key|
      version.edited[key] = old_entity[key] unless old_entity[key] == entity[key]
    end

    version
  end
end