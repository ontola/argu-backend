# Argu Back-End
=============
[![Build Status](https://semaphoreapp.com/api/v1/projects/40e97aeb-334e-4b28-ac4e-844fa5db7c50/289369/badge.png)](https://semaphoreapp.com/fletcher91/argu--2)

## Installing & running locally

Check the [devproxy](https://bitbucket.org/arguweb/devproxy) for most of the docs, since you'll need the other services to use this back-end.

- `git clone https://gitlab.com/ontola/apex`
- `git submodule update`
- Run the other services (database, front-end, etc.). Use the [devproxy](https://bitbucket.org/arguweb/devproxy).
- Install ruby 2.6.1 (preferably using rvm or rbenv) and bundle
- Setup the .env, also using devproxy. Requires Nominatim & Mapbox.
- `bundle install`. If you're on a mac and have `pg_config` errors install postgres `brew install postgresql`, and imagemagick with `brew link --force imagemagick@6`
- `bundle exec rake db:setup`
- `bundle exec rails s -b 0.0.0.0 -p 3000`
- `RAILS_ENV=staging bundle exec rails s -b 0.0.0.0 -p 3000` if you want more performance and less debugging

## Troubleshooting

If you have issues with `bundle install` on your mac:

```sh
brew install postgresql
brew install imagemagick@6
brew link --force imagemagick@6
brew install vips
bundle install
```

If you have migrations pending, or db-related errors, run `bundle exec rake db:migrate`

## Logging in

DB is seeded with user `staff@argu.co` and password `arguargu`.
