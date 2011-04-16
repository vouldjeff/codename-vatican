class Backend::GroupsController < ApplicationController
  
  before_filter :must_sign_in, :except => [:index]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        backend_groups_path
      else
        render :action => :edit
      end
    end
  end

  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        backend_groups_path
      else
        render :action => :edit
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      backend_groups_path
    end
  end
end