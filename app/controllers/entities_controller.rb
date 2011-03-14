class EntitiesController < ApplicationController
  respond_to :html
  
  def show
    @entity = Entity.one_by_key(params[:id])
    
    @namespaces = {}
    @entity.properties.each do |key, value|
      namespace, type_key = *key.split("/")
      @namespaces[namespace] = [] if @namespaces[namespace].nil?
      value["key"] = type_key
      @namespaces[namespace] << value
    end
    
    respond_with @entity, @namespaces
  end
  
  def rdf
    entity = Entity.one_by_key(params[:id])

    @triples = entity.to_triples
    render :text => @triples.join("\r\n")
  end
end
