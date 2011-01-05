class RdfTriplesBuilder  
  DEFAULT_LANG = "bg" # TODO: get it from Rails configuration
  
  def initialize(subject)
    @subject = subject
    @triples = []
    @counter = 1
  end  
    
  def add(predicate, value, options = {})
    if value.kind_of?(Hash)
      raise StandartError, "Cannot convert Hash to RDF triples." # TODO: not finished, for now StandartError
    else
      if value.kind_of?(String)
        if options[:lang].nil?
          value = "\"" + value + "\"@" + DEFAULT_LANG
        elsif options[:lang] == false
          value = "\"" + value + "\""
        else
          value = "\"" + value + "\"@" + options[:lang]
        end
      end
              
      @triples << [@subject, predicate, value]
    end
  end
  
  def to_a
    @triples
  end
end