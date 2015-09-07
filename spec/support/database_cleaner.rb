RSpec.configure do |config|

  config.use_transactional_fixtures = false

  FORUMS = %w(nl houten utrecht holland helsinki cologne)

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:deletion)

    FORUMS.each do |f|
      Apartment::Database.drop(f) rescue nil
      Forum.create!(name: f, subdomain: f)
    end
  end

  config.before(:each) do
    # Switch into the default tenant
    Apartment::Database.switch 'nl'
  end

  config.after(:each) do
    # Reset tentant back to `public`
    Apartment::Database.reset
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
      DatabaseCleaner.strategy = :deletion
    end
  end

end
