source 'https://rubygems.org'

gem 'sass-rails',   '~> 5.0.0.beta1'                                         ###!
gem 'rails', git: 'https://github.com/rails/rails.git' ###!
##################DB########################
gem 'pg', '0.17.1'
#gem 'pg', '0.18.0.pre20141017160319', platform: :mswin
gem 'foreigner', '~> 1.2.1'
gem 'immigrant', '~> 0.1.2'
gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba'

gem 'jbuilder', '~> 1.2'
gem 'bcrypt-ruby', '3.0.1'
gem 'rfc-822', '~> 0.3.0'
gem 'counter_culture', '~> 0.1.25'
gem 'rails-i18n', '~> 4.0.0'
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'tzinfo-data'
gem 'rack-cors', :require => 'rack/cors'
gem 'formtastic', '~> 3.0'
gem 'cocoon'

##################Features########################
gem 'acts-as-taggable-on'
gem 'awesome_nested_set', '~> 3.0.1'
gem 'acts_as_commentable_with_threading', '~> 1.2.0'
#Search

#Pagination
gem 'kaminari', '~>0.15.1'

##################Asset-y########################
#gem 'haml' # TODO: convert haml to slim, then remove this gem
gem 'slim', '~> 2.1.0'
#gem 'slim-rails'
gem 'cells', '~> 4.0.0.alpha1', git: 'https://github.com/apotonick/cells.git'   ###!
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails3-jquery-autocomplete', '~> 1.0.12'
gem 'bootstrap-sass', '~>2.0.1'                                           # This even needed?
gem 'carrierwave'                                                         # Will replace paperclip
gem 'mini_magick'#, require: false                                        # Ruby connector for ImageMagick
gem 'fog'                                                                 # Cloud storage connector for CW

##################User management########################
gem 'devise', "~> 3.4.1"
#gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem "omniauth", "~> 1.2.1"
gem "omniauth-oauth2"
gem 'omniauth-facebook', "~> 1.4.0"
gem 'omniauth-twitter', "~> 0.0.13"
#gem 'omniauth-openid'
gem 'pundit', "~> 0.3.0"
gem 'rolify'

group :development, :test do
  gem 'thin'
  #gem 'puma', platform: :ruby
  gem 'nokogiri', '1.6.3.1'
  gem 'rspec', '2.8.0'
  gem 'rspec-rails', '2.8.0'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'annotate','~> 2.4.1beta1'                      ###!
  gem 'nifty-generators', '~> 0.4.6'
  #gem 'meta_request'
  #gem 'better_errors'
  gem 'binding_of_caller', '>= 0.7.3.pre1'            ###!
  gem 'spring'
  gem 'coffee-rails', '~> 4.0.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'quiet_assets'
  gem 'web-console', '~> 2.0.0.beta4'                 ###!
  ####Capistrano#####
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-bundler', '~> 1.1.2'
  gem 'capistrano-rvm'
end

group :production do 
  #]gem 'newrelic_rpm'
  gem 'therubyracer'
  gem 'rails_12factor'
  gem 'unicorn'
end

source "http://utility.argu.co:3000/" do
  gem 'briarcliff', '~> 0.0.9'
  #gem 'briarcliff', path: '/Users/thom1/Developer/briarcliff', platform: :ruby
  #gem 'briarcliff', path: 'C:\sites\briarcliff', platform: :mswin

  gem 'pica_pica', '~> 0.0.1'
  #gem 'pica_pica', path: '/Users/thom1/Developer/ruby/pica_pica', platform: :ruby
  #gem 'pica_pica', git: 'git@bitbucket.org:fletcher91/pica_pica.git', platform: :mswin
end