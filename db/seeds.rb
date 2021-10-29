# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# raise 'NOMINATIM_KEY is empty, please edit your .env' if ENV['NOMINATIM_KEY'].nil?

load(Dir[Rails.root.join('db/seeds/doorkeeper_apps.seeds.rb')][0])

current_tenant = Apartment::Tenant.current
puts "Seeding #{current_tenant}" # rubocop:disable Rails/Output

if current_tenant == 'public'
  Apartment::Tenant.drop(:argu) if ApplicationRecord.connection.schema_exists?('argu')

  ActiveRecord::Base.transaction do
    Apartment::Tenant.switch('public') do
      Tenant.delete_all
      Tenant.create_system_users unless User.any?
    end
  end
end
