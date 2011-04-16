class MainController < ApplicationController
  def index
  	@namespaces = Namespace.where(:show => true)
  	@groups = Group.all
  end
end
