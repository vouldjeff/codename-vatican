class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from MongoMapper::DocumentNotFound, :with => :document_not_found

  def must_sign_in
    return unless current_user.nil?
  	flash[:error] = "Трябва да влезете, за да получите достъп до тази страница!"
  	redirect_to root_path
  end

  private
  def document_not_found
    render :text => "404 Not Found....", :status => 404 # TODO: customize
  end
end
