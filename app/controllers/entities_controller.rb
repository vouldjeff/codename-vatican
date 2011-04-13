class EntitiesController < ApplicationController
  respond_to :html
  
  def show
    @entity = Entity.one_by_key(params[:id])
    
    unless @entity.is_ok?
      Delayed::Job.enqueue ExtractJob.new(@entity.freebase, {}, true)
    end
    
    @namespaces = {}
    @entity.properties.each do |key, value|
      namespace, type_key = *key.split("/")
      @namespaces[namespace] = [] if @namespaces[namespace].nil?
      value["key"] = type_key
      @namespaces[namespace] << value
    end
    
    respond_with @entity, @namespaces
  end
  
  def edit
    @entity = Entity.one_by_key(params[:id])
    @title = @entity.title
    
    respond_with @entity
  end

  def revisions
    @entity = Entity.one_by_key(params[:id])
    @revisions = EntityHistory.where(:entity => params[:id]).sort(:revision.desc)
    
    respond_with @entity, @revisions
  end
  
  def update
    @entity = Entity.one_by_key(params[:id])
    @title = @entity.title
    
    @entity.attributes = params[:entity]
    if @entity.valid?
      revision = EntityHistory.track @entity
      revision.ip = request.remote_ip
      revision.by = (current_user.nil?) ? 0 : current_user.id
      revision.save
        
      @entity.revision += 1
      @entity.save
      flash[:notice] = "Успешно обновите ресурс."
    end
    respond_with @entity
  end
  
  def rdf
    entity = Entity.one_by_key(params[:id])

    @triples = entity.to_triples
    render :text => @triples.join("\r\n")
  end
end
