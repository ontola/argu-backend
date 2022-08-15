# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Thread.current[:mock_searchkick] = true

    DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
    DatabaseCleaner.strategy = :transaction

    extend FactoryBot::Syntax::Methods
    extend Argu::TestHelpers::TestHelperMethods::InstanceMethods

    load(Dir[Rails.root.join('db/seeds/test.seeds.rb')][0])
    forum = Forum.find_via_shortname('freetown')
    forum.initial_public_grant = :spectator
    forum.send(:create_default_grant)
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
  end
end
