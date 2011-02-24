class EntitiesController < ApplicationController
  respond_to :html
  
  def show
    @entity = Entity.one_by_key(params[:key])
    
    @namespaces = {}
    @entity.properties.each do |key, value|
      namespace = key.split("/")[1]
      @namespaces[namespace] = [] if @namespaces[namespace].nil?
      @namespaces[namespace] << value
    end
    
    respond_with @entity, @namespaces
  end
  
  def show_rdf
    entity = Entity.one_by_key(params[:key])

    @triples = entity.to_triples
    render :text => @triples.join("\r\n")
  end
end
