class MainController < ApplicationController
  def index
  	@namespaces = Namespace.all
  	@types = Type.all
  end
end
