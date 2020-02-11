# frozen_string_literal: true

source 'https://rubygems.org/'
ruby '2.6.3'
ruby = '2.6.3'

gem 'active_response', git: 'https://github.com/ontola/active_response', branch: :master
gem 'acts_as_tenant', git: 'https://github.com/ArthurWD/acts_as_tenant', branch: :master
gem 'apartment', git: 'https://github.com/ArthurWD/apartment', ref: '9d2db15'
gem 'bootsnap', require: false
gem 'bunny', '~> 2.6.1'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'rails', '~>5.2.2.1'
gem 'active_model_serializers', '~> 0.10.7'
gem 'oj'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails'
gem 'logstasher', '~> 1.2.0'
gem 'uri_template'
gem 'health_check'
gem 'rdf'
gem 'rdf-n3'
gem 'rdf-serializers', git: 'https://github.com/ontola/rdf-serializers'
gem 'rdf-turtle'
gem 'json-ld'
gem 'rdf-vocab'
gem 'rdf-rdfa'
gem 'rdf-rdfxml', git: 'https://github.com/ruby-rdf/rdf-rdfxml', ref: 'dd99a73'
gem 'ebnf', git: 'https://github.com/dryruby/ebnf', ref: '3631273'
gem 'erubis'
gem 'puma', platform: :ruby
gem 'sequenced'
gem 'spreadsheet'
gem 'pg'
gem 'active_record-postgres-constraints',
    git: 'https://github.com/ArthurWD/active_record-postgres-constraints',
    ref: '1daecf7'
gem 'bcrypt-ruby', '>= 3.1.5'
gem 'rfc-822', '~> 0.4.1'
gem 'counter_culture', '~> 1.8.2'
gem 'rails-i18n', '~> 5.0.4'
gem 'tzinfo-data'
gem 'redis', '~> 3.3.5'
gem 'rest-client'
gem 'ltree_hierarchy'
gem 'public_activity', '~> 1.5'
gem 'acts_as_follower',
    git: 'https://github.com/tcocca/acts_as_follower.git',
    ref: 'ff4a7d1f8206be13b9b68526a5062611f36509aa'
gem 'jwt'
gem 'doorkeeper', '~> 5.0.2'
gem 'doorkeeper-jwt', '~> 0.1.6'
gem 'rack-attack', '~> 4.3.1'
gem 'country_select'
gem 'http_accept_language'
gem 'auto_strip_attributes', '~> 2.0.6'
gem 'wisper', '~> 1.6.1'
gem 'cocoon', '~> 1.2.6'
gem 'httparty', '~> 0.13.7'
gem 'acts_as_list'
gem 'kaminari', '~>0.17.0'
gem 'rubyzip'
gem 'searchkick'
gem 'carrierwave', '~> 0.11.2'
gem 'carrierwave_backgrounder', '~> 0.4.1'
gem 'carrierwave-vips', '~> 1.2.0'
gem 'carrierwave-aws', '~> 1.3.0'
gem 'image_optim', '~> 0.25.0'
gem 'image_optim_pack', '~> 0.5.0'
gem 'image_optim_rails', '~> 0.4.1'
gem 'sidekiq', '~> 4.2.2'
gem 'sidekiq-prometheus-exporter', '~> 0.1'
gem 'sidetiq', '~> 0.7.2'
gem 'sidekiq-logging-json',
    git: 'https://github.com/st0012/Sidekiq-Logging-JSON.git',
    ref: '08098971d5baa75f05bb3b9d53d2d0e811d0ebc1'
gem 'video_info'
gem 'devise'
gem 'devise-multi_email', '~> 2.0.1', git: 'https://github.com/allenwq/devise-multi_email', ref: 'c3823'
gem 'oauth2', '~> 1.2.0'
gem 'pundit', '~> 1.0.0'
gem 'bugsnag'

group :test do
  gem 'addressable', '~> 2.3.8'
  gem 'minitest', '5.10.3'
  gem 'minitest-rails', '~> 3.0.0'
  gem 'minitest-reporters', '~> 1.3.0'
  gem 'minitest-bang'
  gem 'minitest-have_tag', '~> 0.1.0'
  gem 'rspec-rails', '~> 3.7.2'
  gem 'rspec-retry', '~> 0.5.6'
  gem 'mocha'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'bundler-audit', '~> 0.6.1'
  gem 'wisper-minitest', '~> 0.0.3', require: false
  gem 'wisper-rspec', require: false
  gem 'fakeredis', '~> 0.6.0', require: false
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'rails-controller-testing'
  gem 'rack-test'
end

group :development, :test do
  gem 'brakeman'
  gem 'license_finder'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'spring', '~> 2.0.2'
  gem 'spring-commands-rspec'
  gem 'spring-commands-testunit'
end

group :development do
  gem 'pry'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1' # ##!
  gem 'yard'
  gem 'yard-activesupport-concern'
  gem 'web-console', '~> 3.5.1'
  gem 'active_record_query_trace'
  gem 'bullet'
end

group :staging, :development do
  gem 'rack-mini-profiler', require: false
  gem 'stackprof'
  gem 'flamegraph'
end
