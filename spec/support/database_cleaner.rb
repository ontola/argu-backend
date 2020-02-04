# frozen_string_literal: true

RSpec.configure do |config|
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
end
