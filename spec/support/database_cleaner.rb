# frozen_string_literal: true

RSpec.configure do |config|
  if ENV['RSPEC_TRANSACTION']
    config.before(:suite) do
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])

      DatabaseCleaner.strategy = :transaction

      extend FactoryBot::Syntax::Methods
      extend Argu::TestHelpers::TestHelperMethods::InstanceMethods

      load(Dir[Rails.root.join('db', 'seeds', 'test.seeds.rb')][0])
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
      DatabaseCleaner.clean_with(:deletion, except: %w[ar_internal_metadata])
      DatabaseCleaner.strategy = :deletion
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

      DatabaseCleaner.strategy = :deletion if example.metadata[:clean_db_strategy]
    end
  end
end
