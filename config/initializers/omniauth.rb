Rails.application.config.middleware.use OmniAuth::Builder do
	#require 'openid/store/filesystem'

	provider :twitter, 'uDvXQqkzxeEyyP2fk08YQ', 'XmZfulWYq8XUXBE0eII5LVPgMR0l0J9U4NotXIElN0'
	#provider :facebook, '269911176456825', 'ed0c2c861fa37c1bb6b94dfe8d85f75e', scope: 'email'
	#provider :openid, :store => OpenID::Store::Filesystem.new('/tmp'), name: 'openid'
end