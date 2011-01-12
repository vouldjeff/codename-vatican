class RdfTriplesBuilder  
  DEFAULT_LANG = "bg" # TODO: get it from Rails configuration
  
  def initialize(subject)
    @subject = subject
    @triples = []
    @counter = 1
  end  
    
  def add(predicate, value, options = {})
    if value.kind_of? Time
      value = value
    elsif value.kind_of? Hash
      
      if value["key"].nil? and value["value"].kind_of? String
        if options[:lang].nil?
          value = "\"" + value["value"] + "\"@" + DEFAULT_LANG
        elsif options[:lang] == false
          value = "\"" + value["value"] + "\""
        else
          value = "\"" + value["value"] + "\"@" + options[:lang]
        end
      else
        value = value["value"] # TODO: fix.. add other cases
      end
      
    else
      value = value
    end     
         
    @triples << "#{@subject} #{predicate} #{value} ."
  end
  
  def to_a
    @triples
  end
end