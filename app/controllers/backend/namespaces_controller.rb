class Backend::NamespacesController < ApplicationController
  # TODO: add administrator protection
  
  def index
    @namespaces = Namespace.all
  end
  
  def edit
    @namespace = Namespace.one_by_key(params[:id])
    @title = @namespace.get_name
  end
  
  def update
    @namespace = Namespace.one_by_key(params[:id])
    @title = @namespace.get_name
    
    if @namespace.update_attributes(params[:namespace])  
      flash[:notice] = "Успешно обновите тип."
      redirect_to backend_namespaces_path
    else
      render :action => :edit
    end
  end
end
