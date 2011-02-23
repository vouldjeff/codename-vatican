class User
  include MongoMapper::Document
  plugin MongoMapper::Devise
  devise :registerable, :database_authenticatable, :recoverable, :rememberable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  many :authentications

  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    authentications << Authentication.new(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
