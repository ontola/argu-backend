RSpec.configure do |config|

  config.use_transactional_fixtures = false

  # config.before(:suite) do
  #   DatabaseCleaner.clean_with :deletion
  #   DatabaseCleaner.strategy = :transaction
  #   Rails.application.load_seed
  # end
  #
  # config.before(:each) do
  #   DatabaseCleaner.start
  # end
  #
  # config.before(:each, :js => true) do
  #   DatabaseCleaner.strategy = :deletion
  #   DatabaseCleaner.start
  # end
  #
  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:transaction)
  end

  # If an example has one of the following options: :js, :driver
  # the connection to the databas e will be shared to Capybara thread.
  # Option :clean_db_strategy allows to set any of three strategies available in
  # DatabaseCleaner: :transaction, :truncation, :deletion. The default and the fastest
  # value is :transaction.
  config.around(:each) do |example|
    if example.metadata[:clean_db_strategy]
      DatabaseCleaner.strategy = example.metadata[:clean_db_strategy]
    end

    DatabaseCleaner.cleaning do
      if example.metadata[:js] || example.metadata[:driver]
        ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
        example.run
        ActiveRecord::Base.shared_connection = nil
      else
        example.run
      end
    end

    if example.metadata[:clean_db_strategy]
      DatabaseCleaner.strategy = :transaction
    end
  end

end
