source 'https://rubygems.org'
ruby '2.0.0'

gem 'sass-rails',   '~> 4.0.3'
gem 'rails', '~>4.1.0'
##################DB########################
gem 'pg', '~> 0.17.1'
gem 'foreigner', '~> 1.2.1'
gem 'immigrant', '~> 0.1.2'

gem 'jbuilder', '~> 1.2'
gem 'bcrypt-ruby', '3.0.1'
gem 'rfc-822', '~> 0.3.0'
gem 'counter_culture', '~> 0.1.25'
gem 'rails-i18n', '~> 4.0.0'
gem 'capistrano'
gem 'delayed_job', '~> 4.0.1'
gem 'delayed_job_active_record', '~> 4.0.1'
gem 'tzinfo-data'
gem 'rack-cors', :require => 'rack/cors'
gem 'formtastic', '~> 3.0'
gem "cocoon"
gem 'activerecord-session_store', github: 'rails/activerecord-session_store'
gem 'yaml_db', github: 'jetthoughts/yaml_db', ref: 'fb4b6bd7e12de3cffa93e0a298a1e5253d7e92ba'

##################Features########################
gem 'paper_trail', '~> 3.0.0'
gem 'acts-as-taggable-on'
gem 'awesome_nested_set', '~> 3.0.1'
gem 'acts_as_commentable_with_threading', '~> 1.2.0'
#Search
gem 'sunspot_rails'
gem 'sunspot_solr'
#Pagination
gem 'kaminari', '~>0.15.1'
gem "sunspot_with_kaminari", '~> 0.2.0'

##################Asset-y########################
gem 'haml' # TODO: convert haml to slim, then remove this gem
gem 'slim', '~>2.0.2'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rails3-jquery-autocomplete', '~> 1.0.12'
gem 'bootstrap-sass', '~>2.0.1'                                           # This even needed?
gem "paperclip", "~> 4.2"
gem "papercrop"

##################User management########################
gem 'devise', "~> 3.2.4"
#gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git'
gem "omniauth", "~> 1.0.0"
gem "omniauth-oauth2"
gem 'omniauth-facebook', "~> 1.4.0"
gem 'omniauth-twitter', "~> 0.0.13"
#gem 'omniauth-openid'
gem 'pundit', "~> 0.3.0"
gem 'rolify'

group :development, :test do
  #gem 'thin'
  gem 'puma'
  gem 'rspec', '2.8.0'
  gem 'rspec-rails', '2.8.0'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'annotate','~> 2.4.1beta1'
  gem "nifty-generators", '~> 0.4.6'
  gem 'meta_request'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'spring'
  gem 'coffee-rails', '~> 4.0.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'quiet_assets'

end

group :production do 
  gem 'newrelic_rpm'
  gem 'therubyracer'
end