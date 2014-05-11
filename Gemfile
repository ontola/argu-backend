source 'https://rubygems.org'

gem 'rails', '~>3.2.3'
gem 'pg', '~> 0.13.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'x-editable-rails'
gem 'requirejs-rails'
gem 'bcrypt-ruby', '3.0.1'
gem 'bootstrap-sass', '~>2.0.1'
gem 'rfc-822', '~> 0.3.0'
gem 'rails3-jquery-autocomplete', '~> 1.0.7'
gem 'foreigner', '~> 1.2.1'
gem 'immigrant', '~> 0.1.2'
gem 'acts_as_commentable_with_threading', '~> 1.1.2'
gem 'paper_trail', '~> 3.0.0'
gem 'devise', "~> 2.1.2"
#gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem "omniauth", "~> 1.0.0"
gem "omniauth-oauth2", "~> 1.0.0"
gem 'omniauth-facebook', "~> 1.4.0"
gem 'omniauth-twitter', "~> 0.0.13"
#gem 'omniauth-openid'
gem 'cancan'
gem 'rolify'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'rails-i18n'
gem "thumbs_up", "~> 0.6.2"
gem 'capistrano'
gem 'kaminari', '~>0.15.1'
gem "sunspot_with_kaminari", '~> 0.2.0'
gem 'acts-as-taggable-on'
gem 'haml' # TODO: convert haml to slim, then remove this gem
#gem 'tilt', '~>1.3.3'
gem 'slim', '~>2.0.2'
gem 'delayed_job'
gem 'delayed_job_active_record'

##### Gems already in Rails 4
gem 'postgres_ext' # When migrating to 4, don't forget to remove this and require 'postgres_ext' in application.rb
#####

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'thin'
  gem 'rspec', '2.8.0'
  gem 'rspec-rails', '2.8.0'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'annotate','~> 2.4.1beta1'
  gem "nifty-generators", '~> 0.4.6'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :production do 
  gem 'newrelic_rpm'
  gem 'therubyracer'
end