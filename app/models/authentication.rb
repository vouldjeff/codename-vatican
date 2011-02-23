class Authentication
  include MongoMapper::EmbeddedDocument
  
  key :provider, String
  key :uid, String

  embedded_in :user

  def provider_name
    if provider == 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end
end
