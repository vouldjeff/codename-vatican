class NamespacesController < ApplicationController
  def index
  	@namespaces = Namespace.all
  end 
  
  def show
  	@namespace = Namespace.one_by_key(params[:id])
    @children = Namespace.all(:parent => @namespace.key)
    
    @types = Type.all(:namespace => @namespace.key)
  end
end
