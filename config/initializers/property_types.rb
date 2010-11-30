# TODO: check wheather the class caches itself in production

module PropertyTypes
  def self.load_conf
    raw_config = File.read(Rails.root.to_s + "/config/property_types.yml")
    @config = YAML.load(raw_config)
    end
  
  def self.[](key)
    unless @config
      load_conf
      @config.each do |key, value|
        @config[key]["ruby_type"] = value["ruby_type"].constantize
      end
    end
    
    if @config.key?(key)
      @config[key]["ruby_type"]
    else
      nil
    end
  end
  
  def self.keys
    if @to_a.nil?
      if @config.nil?
        load_conf
      end
      
      @to_a = @config.keys
    end
    @to_a
  end
end