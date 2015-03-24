source 'https://rubygems.org'
source 'http://utility.argu.co:3000/'

gem 'sass-rails',   '~> 5.0.0'
gem 'rails', '~>4.2.0'

gem 'simple_text', '~> 0.0.21'
gem 'indefinite_article'
gem 'logstasher'
gem 'bugsnag'

##################DB########################
gem 'pg', '0.17.1'

gem 'jbuilder', '~> 2.2.5'
gem 'bcrypt-ruby', '>= 3.1.5'
gem 'rfc-822', '~> 0.4.0'
gem 'counter_culture', '~> 0.1.27'
gem 'rails-i18n', '~> 4.0.3'
gem 'tzinfo-data'
gem 'rack-cors', :require => 'rack/cors'
gem 'formtastic', '~> 3.1.2'
gem 'cocoon', '~> 1.2.6'
gem 'redis', '~> 3.2.0'
gem 'has_secure_token'
gem 'rest-client'
gem 'multimap'

##################Features########################
gem 'acts-as-taggable-on', '~> 3.4.2'
gem 'awesome_nested_set', '~> 3.0.1'
gem 'acts_as_commentable_with_threading', '~> 2.0.0'
gem 'whodunnit', '0.0.5'
gem 'simple_settings', '1.0.2'
gem 'public_activity'
gem 'acts_as_follower'
gem 'rollout'
gem 'html_truncator', '~>0.2'
#Search

#Pagination
gem 'kaminari', '~>0.16.1'


##################Front-end########################
gem 'react-rails', github: 'reactjs/react-rails', branch: 'master', ref: 'd0d62c5dd35108e258b8e50d749499269997186d'

##################Asset-y########################
gem 'haml' # TODO: convert haml to slim, then remove this gem
gem 'slim', '~> 2.1.0'
#gem 'slim-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails3-jquery-autocomplete', '~> 1.0.14'
gem 'bootstrap-sass', '~>2.0.1'                                           # This even needed?
gem 'carrierwave', '~> 0.10.0'
gem 'carrierwave_backgrounder', '~> 0.4.1'
gem 'mini_magick', '~> 3.8.1'                                             # Ruby connector for ImageMagick
#gem 'fog', '~> 1.26.0'                                                    # Cloud storage connector for CW
gem 'carrierwave-aws'
gem 'sidekiq', '~> 3.3.0'
gem 'sidekiq-logging-json'
gem 'sinatra', '>= 1.3.0'
gem 'render_anywhere', :require => false
gem 'jquery-pjax-rails'
gem 'rack-pjax'
gem 'uglifier', '>= 2.5.3'

##################User management########################
gem 'devise', '~> 3.4.1'
gem 'devise_invitable', '~> 1.4.0'
#gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem 'omniauth', '~> 1.2.2'
gem 'omniauth-oauth2', '~> 1.2.0'
gem 'omniauth-facebook', '~> 2.0.0'
gem 'omniauth-twitter', '~> 1.1.0'
#gem 'omniauth-openid'
gem 'pundit', '~> 0.3.0'
gem 'rolify', '~> 3.4.1'

group :development, :test do
  gem 'thin'
  #gem 'puma', platform: :ruby
  gem 'nokogiri', '1.6.5'
  gem 'minitest-rails', '~> 2.1.1'
  gem 'minitest-reporters', '~> 1.0.8'
  gem 'byebug'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1'            ###!
  gem 'spring', '~> 1.2.0'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'quiet_assets'
  gem 'web-console', '~> 2.0.0'
  ####Capistrano#####
  gem 'capistrano', '~> 3.3.3'
  gem 'capistrano-rails', '~> 1.1.2'
  gem 'capistrano-bundler', '~> 1.1.3'
  gem 'capistrano-rvm', '~> 0.1.2'
end

group :production, :staging do
  gem 'therubyracer', '~> 0.12.1'
  gem 'unicorn', '~> 4.8.3'
  gem 'rack-test', '~> 0.6.2'
end

group :staging, :development do
  gem 'rack-mini-profiler'
  gem 'stackprof'
  gem 'flamegraph'
end

  gem 'briarcliff', '~> 0.0.9'
  #gem 'briarcliff', path: '/Users/thom1/Developer/briarcliff', platform: :ruby
  #gem 'briarcliff', path: 'C:\sites\briarcliff', platform: :mswin

  gem 'pica_pica', '~> 0.0.1'
  #gem 'pica_pica', path: '/Users/thom1/Developer/ruby/pica_pica', platform: :ruby
  #gem 'pica_pica', git: 'git@bitbucket.org:fletcher91/pica_pica.git', platform: :mswin
