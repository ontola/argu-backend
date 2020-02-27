# frozen_string_literal: true

source 'https://rubygems.org/'
ruby '2.7.0'
ruby = '2.7.0'

gem 'active_model_serializers'
gem 'active_record-postgres-constraints',
    git: 'https://github.com/ArthurWD/active_record-postgres-constraints',
    ref: '1daecf7'
gem 'active_response', git: 'https://github.com/ontola/active_response', branch: :master
gem 'acts_as_follower',
    git: 'https://github.com/tcocca/acts_as_follower.git',
    ref: 'ff4a7d1f8206be13b9b68526a5062611f36509aa'
gem 'acts_as_list'
gem 'acts_as_tenant', git: 'https://github.com/ArthurWD/acts_as_tenant', branch: :master
gem 'apartment', git: 'https://github.com/ArthurWD/apartment', ref: '9d2db15'
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
gem 'devise-multi_email', '~> 2.0.1', git: 'https://github.com/allenwq/devise-multi_email', ref: 'c3823'
gem 'doorkeeper'
gem 'doorkeeper-jwt'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'ebnf', git: 'https://github.com/dryruby/ebnf', ref: '3631273'
gem 'erubis'
gem 'factory_bot'
gem 'factory_bot_rails'
gem 'health_check'
gem 'http_accept_language'
gem 'httparty'
gem 'json-ld'
gem 'jwt'
gem 'kaminari-activerecord'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails'
gem 'ltree_hierarchy'
gem 'oauth2'
gem 'oj'
gem 'pg'
gem 'public_activity'
gem 'puma', platform: :ruby
gem 'pundit'
gem 'rack-attack'
gem 'rails', '~>5.2.2.1'
gem 'rails-i18n'
gem 'rdf'
gem 'rdf-n3'
gem 'rdf-rdfa'
gem 'rdf-rdfxml', git: 'https://github.com/ruby-rdf/rdf-rdfxml', ref: 'dd99a73'
gem 'rdf-serializers', git: 'https://github.com/ontola/rdf-serializers'
gem 'rdf-turtle'
gem 'rdf-vocab'
gem 'redis'
gem 'rest-client'
gem 'rfc-822'
gem 'rubyzip'
gem 'searchkick'
gem 'sequenced'
gem 'sidekiq'
gem 'sidekiq-logging-json',
    git: 'https://github.com/st0012/Sidekiq-Logging-JSON.git',
    ref: '08098971d5baa75f05bb3b9d53d2d0e811d0ebc1'
gem 'sidekiq-prometheus-exporter'
gem 'sidetiq'
gem 'spreadsheet'
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
