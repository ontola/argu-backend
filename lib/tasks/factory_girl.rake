# frozen_string_literal: true

# lib/tasks/factory_bot.rake
namespace :factory_bot do
  # Models only used in context of other models
  EXCLUDED_FACTORIES = %i[shortname identity vote memberships].freeze

  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        factories_to_lint = FactoryBot.factories.reject do |factory|
          EXCLUDED_FACTORIES.include?(factory.name)
        end
        FactoryBot.lint factories_to_lint
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
    end
  end
end
