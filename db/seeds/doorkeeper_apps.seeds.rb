# frozen_string_literal: true

argu_app = Doorkeeper::Application.find_or_create_by(id: Doorkeeper::Application::ARGU_ID) do |app|
  app.id = Doorkeeper::Application::ARGU_ID
  app.name = 'Argu'
  app.owner_type = 'Profile'
  app.owner_id = Profile::COMMUNITY_ID
  app.redirect_uri = 'http://example.com/'
  app.scopes = 'guest user staff'
end
argu_app.save(validate: false)
# rubocop:disable Rails/SkipsModelValidations
argu_app.update_columns(uid: ENV['LIBRO_CLIENT_ID'], secret: ENV['LIBRO_CLIENT_SECRET']) if ENV['LIBRO_CLIENT_ID']
# rubocop:enable Rails/SkipsModelValidations
Doorkeeper::Application.find_or_create_by(id: Doorkeeper::Application::AFE_ID) do |app|
  app.id = Doorkeeper::Application::AFE_ID
  app.name = 'Argu Front End'
  app.owner_type = 'Profile'
  app.owner_id = Profile::COMMUNITY_ID
  app.redirect_uri = 'http://example.com/'
  app.scopes = 'guest user staff'
end.save(validate: false)
Doorkeeper::Application.find_or_create_by(id: Doorkeeper::Application::SERVICE_ID) do |app|
  app.id = Doorkeeper::Application::SERVICE_ID
  app.name = 'Argu Service'
  app.owner_type = 'Profile'
  app.owner_id = Profile::COMMUNITY_ID
  app.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  app.scopes = 'service worker export'
end.save(validate: false)

ActiveRecord::Base.connection.execute(
  "ALTER SEQUENCE #{Doorkeeper::Application.table_name}_id_seq RESTART WITH #{Doorkeeper::Application.count}"
)
