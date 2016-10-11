# frozen_string_literal: true
source 'https://rubygems.org/'
ruby '2.3.1'
ruby = '2.3.1'

gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'sass-rails', '~> 5.0.6'
gem 'sass', '= 3.4.18'
gem 'rails', '~>5.0.0.1'
gem 'active_model_serializers', '~> 0.10.2'

gem 'simple_text', '~> 0.0.23'
gem 'indefinite_article'
gem 'logstasher'

################## DB ########################
gem 'pg', '0.18.2'

gem 'jbuilder', '~> 2.6.0'
gem 'bcrypt-ruby', '>= 3.1.5'
gem 'rfc-822', '~> 0.4.0'
gem 'counter_culture', '~> 0.1.34'
gem 'rails-i18n', '~> 5.0.0'
gem 'i18n-js', '>= 3.0.0.rc12'
gem 'tzinfo-data'
gem 'rack-cors', require: 'rack/cors'
gem 'formtastic', '~> 3.1.4'
gem 'redis', '~> 3.3.1'
gem 'has_secure_token'
gem 'rest-client'
gem 'multimap',
    git: 'https://github.com/apalmblad/multimap.git',
    ref: '96eeacc1606ea7f008ce0a50641c31a2c844fd9e'
gem 'squirm_rails', require: 'squirm/rails'
gem 'ltree_hierarchy'

################## Features ########################
gem 'acts-as-taggable-on', '~> 4.0.0'
gem 'awesome_nested_set', '~> 3.1.1'
gem 'acts_as_commentable_with_threading', '~> 2.0.0'
gem 'whodunnit', '0.0.5'
gem 'simple_settings', '1.0.3'
gem 'public_activity', '~> 1.5'
gem 'acts_as_follower',
    git: 'https://github.com/tcocca/acts_as_follower.git',
    ref: 'ff4a7d1f8206be13b9b68526a5062611f36509aa'
gem 'rollout'
gem 'html_truncator', '~>0.2'
gem 'jwt'
gem 'doorkeeper', '~> 4.2.0'
gem 'rack-attack', '~> 4.3.1'
gem 'country_select'
gem 'http_accept_language'
gem 'geokit-rails', '2.2.0'
gem 'browser'
gem 'addressable', '~> 2.3.8'
gem 'auto_strip_attributes', '~> 2.0.6'
gem 'mailgun_rails', '0.7.0'
gem 'wisper', '~> 1.6.1'
# gem 'wisper-activerecord', '~> 0.3.0'
gem 'roadie', '~> 3.1.1'
gem 'roadie-rails', '~> 1.1.1'
gem 'cocoon', '~> 1.2.6'
gem 'httparty', '~> 0.13.7'
gem 'acts_as_list', '~> 0.7.2'
# Pagination
gem 'kaminari', '~>0.17.0'
gem 'staccato', '~> 0.4.7'

################## Asset-y ########################
gem 'slim', '~> 3.0.6'
# gem 'slim-rails'
gem 'jquery-rails', '~> 4.2.1'
gem 'jquery-ui-rails'
gem 'rails3-jquery-autocomplete', '~> 1.0.14'
gem 'carrierwave', '~> 0.11.2'
gem 'carrierwave_backgrounder', '~> 0.4.1'
gem 'carrierwave-vips'
# gem 'rmagick', '2.14.0'
# Cloud storage connector for CW
# gem 'fog', '~> 1.26.0'
gem 'carrierwave-aws', '~> 1.0.1'
gem 'sidekiq', '~> 4.2.2'
gem 'sidetiq', '~> 0.7.2'
gem 'sidekiq-logging-json',
    git: 'https://github.com/st0012/Sidekiq-Logging-JSON.git',
    ref: '08098971d5baa75f05bb3b9d53d2d0e811d0ebc1'
gem 'render_anywhere', require: false
gem 'uglifier', '>= 2.5.3'
gem 'sprockets', '~>3.6.3'
gem 'sprockets-es6', require: 'sprockets/rails'
gem 'font-awesome-rails', '~> 4.6.3'
gem 'babel-transpiler'
gem 'redcarpet', '~> 3.3.4'
# gem 'browserify-rails', '~> 1.4.0', require: 'browserify-rails'

################## User management ########################
gem 'devise', '~> 4.2.0'
gem 'omniauth', '~> 1.3.1'
gem 'omniauth-oauth2', '~> 1.2.0'
gem 'omniauth-facebook', '~> 3.0.0'
gem 'koala', '~> 2.3.0'
gem 'omniauth-twitter', '~> 1.2.0'
# gem 'omniauth-openid'
gem 'pundit', '~> 1.0.0'
gem 'bugsnag', '~> 4.2.1'
gem 'rolify', '~> 3.4.1'

################## Front-end ########################
# gem 'react-rails', '~> 1.6.0'
gem 'react-rails',
    git: 'https://github.com/reactjs/react-rails',
    branch: 'master',
    ref: '58842d4d06cf4a7f993a112edbd3ef82272a659a'

group :test do
  gem 'minitest-rails', '~> 3.0.0'
  gem 'minitest-reporters', '~> 1.1.8'
  gem 'minitest-bang'
  gem 'minitest-have_tag', '~> 0.1.0'
  gem 'rspec-rails', '~> 3.5.2'
  gem 'capybara', '~> 2.7.1'
  gem 'capybara-webkit', '~> 1.11.1'
  gem 'capybara-email', '~> 2.5.0'
  gem 'selenium-webdriver', '~> 2.53.4'
  gem 'poltergeist'
  gem 'chromedriver-helper'
  gem 'testingbot'
  gem 'mocha'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'license_finder'
  gem 'database_cleaner'
  gem 'bundler-audit', '~> 0.5.0'
  gem 'wisper-minitest', '~> 0.0.3', require: false
  gem 'wisper-rspec', require: false
  gem 'fakeredis', require: false
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'rubocop', '~> 0.43.0'
  gem 'spring', '~> 1.7.2'
  gem 'spring-commands-rspec'
  gem 'spring-commands-testunit'
  gem 'brakeman', '~> 3.2.1'
end

group :development do
  gem 'nokogiri', '~> 1.6.8'
  gem 'pry'
  # gem 'byebug'
  # gem 'pry-byebug'
  gem 'meta_request', '~> 0.4.0'
  gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1' # ##!
  gem 'coffee-rails', '~> 4.2.1'
  gem 'yard'
  gem 'yard-activesupport-concern'
  gem 'web-console', '~> 3.1.1'
  gem 'active_record_query_trace'
  # gem 'puma', platform: :ruby
end

group :production, :staging do
  gem 'libv8', '~> 3.16.14.13'
  gem 'therubyracer', '~> 0.12.2'
  gem 'unicorn', '5.0.1'
  gem 'rack-test', '~> 0.6.2'
end

group :staging, :development do
  gem 'rack-mini-profiler', require: false
  gem 'stackprof'
  gem 'flamegraph'
end

#  gem 'briarcliff', '~> 0.0.9'
#  gem 'pica_pica', '~> 0.0.1'
