# frozen_string_literal: true

Apartment::Tenant.create('argu') unless ApplicationRecord.connection.schema_exists?('argu')
Apartment::Tenant.switch('public') do
  Tenant.delete_all
  Tenant.create_system_users unless User.any?
end
Apartment::Tenant.switch!('argu')

DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
DatabaseCleaner.strategy = :transaction

load(Dir[Rails.root.join('db', 'seeds', 'doorkeeper_apps.seeds.rb')][0])

Tenant.seed_schema('argu', "app.#{Rails.application.config.host_name}/public_page", 'public_page')

ActsAsTenant.current_tenant = nil

module ActiveSupport
  class TestCase
    before(:each) do
      DatabaseCleaner.start
    end

    after(:each) do
      DatabaseCleaner.clean
    end
  end
end
