class GroupsController < ApplicationController
  def show
  	@group = Group.one_by_key(params[:id])

    @types = Type.all(:group => @group.key)
  end  
end
