# frozen_string_literal: true

source 'https://rubygems.org/'
ruby '2.7.0'
ruby = '2.7.0'

gem 'active_model_otp'
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
gem 'counter_culture'
gem 'country_select'
gem 'devise'
gem 'devise-multi_email'
gem 'doorkeeper'
gem 'doorkeeper-jwt'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'factory_bot'
gem 'factory_bot_rails'
gem 'fast_jsonapi', git: 'https://github.com/fast-jsonapi/fast_jsonapi', ref: '2de80d48896751d30fb410e042fd21a710100423'
gem 'health_check'
gem 'http_accept_language'
gem 'httparty'
gem 'json-ld'
gem 'jsonapi-renderer'
gem 'jwt'
gem 'kaminari-activerecord'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails', branch: :refactor
gem 'linked_rails-auth', git: 'https://github.com/ontola/linked_rails-auth', branch: :refactor
gem 'ltree_hierarchy'
gem 'money'
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
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
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
