# frozen_string_literal: true

source 'https://rubygems.org/'
ruby '2.7.0'
ruby = '2.7.0'

gem 'active_model_serializers'
gem 'active_record-postgres-constraints'
gem 'active_response', git: 'https://github.com/ontola/active_response', branch: :master
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
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'carrierwave-vips'
gem 'cocoon'
gem 'counter_culture'
gem 'country_select'
gem 'devise'
gem 'devise-multi_email'
gem 'doorkeeper'
gem 'doorkeeper-jwt'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'erubis'
gem 'factory_bot'
gem 'factory_bot_rails'
gem 'health_check'
gem 'http_accept_language'
gem 'httparty'
gem 'json-ld'
gem 'jwt'
gem 'kaminari-activerecord'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails', ref: 'f9337c00e33cb8cb0f79f161ee52fc58238fcd99'
gem 'ltree_hierarchy'
gem 'oauth2'
gem 'oj'
gem 'pg'
gem 'public_activity'
gem 'puma', platform: :ruby
gem 'pundit'
gem 'rack-attack', '~> 4.3.1'
gem 'rails'
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
gem 'ros-apartment', git: 'https://github.com/ArthurWD/apartment', ref: '4eb1681', require: 'apartment'
gem 'rubyzip'
gem 'searchkick'
gem 'sequenced'
gem 'sidekiq', '~> 5.2'
gem 'sidekiq-prometheus-exporter'
gem 'sidetiq'
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
  gem 'fakeredis', require: false
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
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-testunit'
end

group :development do
  gem 'active_record_query_trace'
  gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1' # ##!
  gem 'bullet'
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
