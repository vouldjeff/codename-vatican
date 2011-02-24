class TypesController < ApplicationController
  respond_to :html
  
  def show
    begin
      @type = Type.one_by_key(params[:namespace_id], params[:id], true)
    rescue MongoMapper::DocumentNotFound
      @type = FakeType.new(params[:id].capitalize.tr("_", " "))
    end  
      
    options = {:sort => "title".to_sym.desc}
    @entities = Entity.with_type(params[:namespace_id], params[:id], options)
    
    respond_with @entities
  end
end
