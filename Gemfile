source 'https://rubygems.org'

gem 'rails', '~>3.2.3'
gem 'pg', '~> 0.13.2'
gem 'jquery-rails'
gem 'bcrypt-ruby', '3.0.1'
gem 'bootstrap-sass', '~>2.0.1'
gem 'rfc-822', '~> 0.3.0'
gem 'rails3-jquery-autocomplete', '~> 1.0.7'
gem 'foreigner', '~> 1.2.1'
gem 'immigrant', '~> 0.1.2'
gem 'acts_as_commentable_with_threading', '~> 1.1.2'
gem 'paper_trail', '~> 2.6.3'
gem 'devise', "~> 2.1.2"
#gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem "omniauth", "~> 1.0.0"
gem "omniauth-oauth2", "~> 1.0.0"
gem 'omniauth-facebook', "~> 1.4.0"
gem 'omniauth-twitter', "~> 0.0.13"
#gem 'omniauth-openid'
gem 'cancan', '~> 1.6.8'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'rails-i18n'
gem "thumbs_up", "~> 0.6.2"
gem 'capistrano'
gem 'kaminari'
gem "sunspot_with_kaminari", '~> 0.2.0'
gem 'acts-as-taggable-on'
gem 'haml'

##### Gems already in Rails 4
gem 'postgres_ext' # When migrating to 4, don't forget to remove this and require 'postgres_ext' in application.rb
#####

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'thin'
  gem 'rspec-rails', '2.9.0'
  gem 'annotate','~> 2.4.1beta1'
  gem "nifty-generators", '~> 0.4.6'
end

group :production do 
  gem 'newrelic_rpm'
  gem 'mysql2', '~> 0.3.11'
  gem 'therubyracer'
end