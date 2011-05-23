class Backend::GroupsController < ApplicationController
  
  before_filter :must_sign_in, :except => [:index]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.one_by_key(params[:id])
  end

  def create
    @group = Group.new(params[:group])

    if @group.save
      redirect_to backend_groups_path
    else
      render :action => :edit
    end
  end

  def update
    @group = Group.one_by_key(params[:id])

    if @group.update_attributes(params[:group])
      redirect_to backend_groups_path
    else
      render :action => :edit
    end
  end

  def destroy
    @group = Group.one_by_key(params[:id])
    @group.destroy

    redirect_to backend_groups_path
  end
end
