class AuthenticationsController < ApplicationController
  respond_to :html
  
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    auth_user = User.all("authentications.provider" => omniauth['provider'], "authentications.uid" => omniauth['uid']).first

    if auth_user
      flash[:notice] = "signed-successfully"
      sign_in_and_redirect(:user, auth_user)
    elsif current_user
      current_user.apply_omniauth(omniauth)
      current_user.save!

      flash[:notice] = "auth-successful"
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "signed-in-with-provider-successfully"
        sign_in_and_redirect(:user, user)
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end
end
