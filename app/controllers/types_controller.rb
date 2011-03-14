class TypesController < ApplicationController
  respond_to :html
  
  def show
    @type = Type.one_by_key(params[:namespace_id], params[:id], true)
      
    builder = FormQueryBuilder.new params[:query]
    builder.add_type(params[:namespace_id], params[:id])
    @entities = builder.query
    
    respond_with @entities
  end
end
