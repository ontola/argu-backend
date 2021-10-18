# frozen_string_literal: true

source 'https://rubygems.org/'
ruby '3.0.2'

gem 'active_model_otp'
gem 'active_record-postgres-constraints',
    git: 'https://github.com/on-site/active_record-postgres-constraints.git',
    branch: 'support-rails-6.1'
gem 'acts_as_follower',
    git: 'https://github.com/tcocca/acts_as_follower.git',
    ref: 'ff4a7d1f8206be13b9b68526a5062611f36509aa'
gem 'acts_as_list'
gem 'acts_as_tenant', git: 'https://github.com/ErwinM/acts_as_tenant', ref: '1ba28'
gem 'auto_strip_attributes'
gem 'bcrypt-ruby'
gem 'bootsnap', require: false
gem 'bugsnag'
gem 'bunny'
gem 'carrierwave', '~> 2.1.1'
gem 'carrierwave-aws'
gem 'carrierwave-vips'
gem 'counter_culture'
gem 'country_select'
gem 'devise'
gem 'devise-multi_email', git: 'https://github.com/thiagogabriel/devise-multi_email', ref: 'c50aee1'
gem 'doorkeeper'
gem 'doorkeeper-jwt'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'factory_bot'
gem 'factory_bot_rails'
gem 'health_check'
gem 'httparty'
gem 'jsonapi-renderer'
gem 'json-ld'
gem 'jwt'
gem 'kaminari-activerecord'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails', branch: 'collections-dsl'
gem 'linked_rails-auth', git: 'https://github.com/ontola/linked_rails-auth'
gem 'ltree_hierarchy'
gem 'money'
gem 'oauth2'
gem 'oj'
gem 'pg'
gem 'public_activity', git: 'https://github.com/arthurWD/public_activity', branch: 'rails-6.1'
gem 'puma', platform: :ruby
gem 'pundit'
gem 'rack-attack', '~> 4.3.1'
gem 'rails', '~> 6.1.0'
gem 'rails-i18n'
gem 'rdf'
gem 'rdf-n3'
gem 'rdf-rdfa'
gem 'rdf-rdfxml'
gem 'rdf-serializers', git: 'https://github.com/ontola/rdf-serializers'
gem 'rdf-turtle'
gem 'rdf-vocab'
gem 'redis'
gem 'rest-client'
gem 'rfc-822'
gem 'ros-apartment', require: 'apartment'
gem 'rqrcode'
gem 'rubyzip'
gem 'searchkick'
gem 'sequenced'
gem 'sidekiq'
gem 'sidekiq-prometheus-exporter'
gem 'sidekiq-scheduler'
gem 'spreadsheet'
gem 'sprockets', '~> 3'
gem 'tzinfo-data'
gem 'uri_template'
gem 'video_info'
gem 'wisper'

group :test do
  gem 'addressable'
  gem 'bundler-audit'
  gem 'database_cleaner'
  gem 'fakeredis',
      require: false,
      git: 'https://github.com/magicguitarist/fakeredis',
      branch: 'fix-sadd-return-when-0-or-1'
  gem 'minitest'
  gem 'minitest-bang'
  gem 'minitest-have_tag'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'mocha'
  gem 'rack-test'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'wisper-minitest', require: false
  gem 'wisper-rspec', require: false
end

group :development, :test do
  gem 'brakeman'
  gem 'license_finder'
  gem 'rubocop', '~> 0.92.0'
  gem 'rubocop-rails', '~> 2.5.2'
  gem 'rubocop-rspec', '~> 1.39.0'
end

group :development do
  gem 'active_record_query_trace'
  gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1' # ##!
  gem 'meta_request'
  gem 'pry'
  gem 'web-console', '~> 3.5.1'
  gem 'yard'
  gem 'yard-activesupport-concern'
end

group :staging, :development do
  gem 'flamegraph'
  gem 'rack-mini-profiler', require: false
  gem 'stackprof'
end
