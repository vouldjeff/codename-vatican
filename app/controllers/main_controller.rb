class MainController < ApplicationController
  def index
  	@namespaces = Namespace.where(:show => true)
  	@types = Type.all
  end
end
