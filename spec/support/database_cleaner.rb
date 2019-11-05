# frozen_string_literal: true

RSpec.configure do |config|
  if ENV['RSPEC_TRANSACTION']
    config.before(:suite) do
      Apartment::Tenant.create('argu') unless ApplicationRecord.connection.schema_exists?('argu')
      Apartment::Tenant.switch!('argu')

      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
      DatabaseCleaner.strategy = :transaction

      extend FactoryBot::Syntax::Methods
      extend Argu::TestHelpers::TestHelperMethods::InstanceMethods

      load(Dir[Rails.root.join('db', 'seeds', 'test.seeds.rb')][0])
      Forum.find_via_shortname('freetown').update(public_grant: :spectator)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    config.after(:suite) do
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
    end
  else
    config.before(:suite) do
      Apartment::Tenant.create('argu') unless ApplicationRecord.connection.schema_exists?('argu')
      Apartment::Tenant.switch('public') do
        Tenant.delete_all
        Tenant.create_system_users unless User.any?
      end
      Apartment::Tenant.switch!('argu')

      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
      DatabaseCleaner.strategy = :deletion
    end

    config.before(:each) do
      load(Dir[Rails.root.join('db', 'seeds', 'doorkeeper_apps.seeds.rb')][0])

      Tenant.seed_schema('argu', "#{Rails.application.config.host_name}/argu")

      ActsAsTenant.current_tenant = nil

      {Group => %w[public staff], User => %w[anonymous community], Profile => %w[anonymous community]}.each do |k, v|
        v.each { |var| k.instance_variable_set("@#{var}", nil) }
      end
    end

    config.around(:each) do |example|
      DatabaseCleaner.strategy = example.metadata[:clean_db_strategy] if example.metadata[:clean_db_strategy]

      DatabaseCleaner.cleaning do
        if example.metadata[:js] || example.metadata[:driver]
          ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
          example.run
          ActiveRecord::Base.shared_connection = nil
        else
          example.run
        end
      end
      Apartment::Tenant.switch('public') { Tenant.delete_all }

      DatabaseCleaner.strategy = :deletion if example.metadata[:clean_db_strategy]
    end
  end
end
