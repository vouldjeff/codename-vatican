class FormQueryBuilder
  attr_reader :query
  
  def initialize(opts_hash)
    opts = (opts_hash.nil?) ? {} : opts_hash.dup 
    @query = Entity.where(:is_ok => true)
    
    opts.each do |key, value|
      proccess_param key, value
    end
  end
  
  def add_type(namespace, key)
    @query = @query.where("properties." + namespace + "/" + key => {"$exists" => true})
  end
  
  private
  
  def proccess_param(key, value)
    case key
      when "title" then where("title", nil, value)
      when /^sort_(asc|desc)$/ then sort(value, $1)
      when /^([\w|\/-]+)_date_(lt|gt|lte|gte)$/ then where($1, $2, value, true, {:type => "date"})
      when /^([\w|\/-]+)_(lt|gt|lte|gte)$/ then where($1, $2, value, true, {:type => "float"})
      when /^([\w|\/-]+)_date_(ne|e|like)$/ then where($1, $2, value, true, {:type => "date"})
      when /^([\w|\/-]+)_(ne|e|like)$/ then where($1, $2, value)
      when /^([\w|\/-]+)_(in|nin)$/ then where_in($1, $2, value)
      else return
    end
  end
  
  def add_or(first, second, value)
    @query = @query.where("$or" => [{first => value}, {second => value}])
  end
  
  def proccess_operation(operation, value)
    case operation
      when "e", nil then value
      when "like" then Regexp.new(value, Regexp::IGNORECASE)
      else {"$#{operation}" => value}
    end
  end
  
  def where(field, operation, value, non_string = false, opts = {})
    case opts[:type]
      when "date" then
        time = Chronic.parse(value)
        value = (!time.nil?) ? Date.to_mongo(time.to_date) : nil
      when "float" then value = value.to_f
    end
      
    case field
      when "title" then (!non_string) ? add_or(:title, :aliases, proccess_operation(operation, value)) : nil
      when /^([\w|\/-]+)$/ then 
        f = $1.split("__")
        @query = @query.where("properties." + f[0] + ".type_properties" => {"$elemMatch" => {"key" => f[1], "values" + ((f.count > 2) ? "." + f.from(2).join(".") : "") => proccess_operation(operation, value)}})
    end
  end
  
  def where_in(field, value, operation)
    # TODO
  end
  
  def sort(field, operation)
    case field
      when "title" then @query = @query.sort(:title.send(operation))
      when /^([\w|\/-]+)$/ then @query = @query # Will not work
    end
  end
end