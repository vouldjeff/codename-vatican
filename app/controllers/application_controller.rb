class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from MongoMapper::DocumentNotFound, :with => :document_not_found
  
  private
  def document_not_found
    render :text => "404 Not Found....", :status => 404 # TODO: customize
  end
end
