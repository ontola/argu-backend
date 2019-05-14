# Argu Back-End
=============
[![Build Status](https://semaphoreapp.com/api/v1/projects/40e97aeb-334e-4b28-ac4e-844fa5db7c50/289369/badge.png)](https://semaphoreapp.com/fletcher91/argu--2)

## Installing & running locally

Check the [devproxy](https://bitbucket.org/arguweb/devproxy) for most of the docs, since you'll need the other services to use this back-end.

- `git clone https://bitbucket.org/arguweb/argu`
- `git submodule update`
- Run the other services (database, front-end, etc.). Use the [devproxy](https://bitbucket.org/arguweb/devproxy).
- Install ruby 2.6.1 (preferably using rvm or rbenv)
- Setup the .env, also using devproxy. Requires Nominatim & Mapbox.
- `bundle install`
- `bundle exec rake db:setup`
- `bundle exec rails s -b 0.0.0.0 -p 3000`
