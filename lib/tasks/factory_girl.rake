# frozen_string_literal: true
# lib/tasks/factory_girl.rake
namespace :factory_girl do
  # Models only used in context of other models
  EXCLUDED_FACTORIES = %i(shortname identity vote memberships)

  desc 'Verify that all FactoryGirl factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        factories_to_lint = FactoryGirl.factories.reject do |factory|
          EXCLUDED_FACTORIES.include?(factory.name)
        end
        FactoryGirl.lint factories_to_lint
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
    end
  end
end
