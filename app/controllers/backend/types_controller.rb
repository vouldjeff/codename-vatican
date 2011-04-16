class Backend::TypesController < ApplicationController
  
  before_filter :must_sign_in, :except => [:index]

  def index
    @types = Type.all
  end

  def edit
    @type = Type.find(params[:id])
  end
  
  def update
    @type = Type.find(params[:id])

    if @type.update_attributes(params[:type])
      redirect_to backend_types_path
    else
      render :action => :edit
    end
  end
end