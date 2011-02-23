require 'openid/store/filesystem'
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'N1shnpah6JPHxxDgXPOQ', 'dacz0YT8OxOJksE0Wg5sxrGfbRyrlFguhr8tvppj8'
  provider :facebook, 'APP_ID', 'APP_SECRET'
  provider :open_id, OpenID::Store::Filesystem.new('/tmp')
end
