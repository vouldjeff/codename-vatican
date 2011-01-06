class EntitiesController < ApplicationController
  respond_to :html
  
  def show
    @entity = Entity.where(:key => "/" + params[:namespace] + "/" + params[:key]).limit(1).first
    if @entity.nil?
      render :template => 'error_pages/404', :layout => false, :status => :not_found
      return
    end
    
    @properties = {}
    @entity.properties.each do |key, value|
      namespace = key.split("/")[1]
      @properties[namespace] = [] if @properties[namespace].nil?
      @properties[namespace] << value
    end
    
    respond_with @entity, @properties
  end
  
  def show_rdf
    entity = Entity.where(:key => "/" + params[:namespace] + "/" + params[:key]).limit(1).first
    if entity.nil?
      render :template => 'error_pages/404', :layout => false, :status => :not_found
      return
    end
    @triples = entity.to_triples
    respond_with @triples
  end
end
