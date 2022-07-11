# frozen_string_literal: true

# @TODO Remove when cache registers a client
argu_app = Doorkeeper::Application.find_or_create_by(id: 0) do |app|
  app.id = 0
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

ActiveRecord::Base.connection.execute(
  "ALTER SEQUENCE #{Doorkeeper::Application.table_name}_id_seq RESTART WITH #{Doorkeeper::Application.count}"
)
