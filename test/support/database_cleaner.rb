# frozen_string_literal: true

Thread.current[:mock_searchkick] = true

Apartment::Tenant.create('argu') unless ApplicationRecord.connection.schema_exists?('argu')
Apartment::Tenant.switch('public') do
  Tenant.delete_all
  Tenant.create_system_users unless User.any?
end
Apartment::Tenant.switch!('argu')

DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
DatabaseCleaner.strategy = :transaction

Sidekiq::Testing.inline! do
  Tenant.seed_schema('argu', "#{Rails.application.config.host_name}/public_page", 'public_page')

  ActsAsTenant.current_tenant = nil

  FactorySeeder.create(:page, locale: 'en-GB', url: 'argu', name: 'Argu')
end

module ActiveSupport
  class TestCase
    def before_setup
      Redis::Connection::Memory.reset_all_databases
      super
    end

    before(:each) do
      DatabaseCleaner.start
    end

    after(:each) do
      DatabaseCleaner.clean
    end
  end
end
