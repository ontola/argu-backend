FROM fletcher91/ruby-vips-qt-unicorn:2.4.1
ARG ASSET_HOST

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -y nodejs

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
RUN RAILS_ENV=production bundle install --deployment --frozen --clean --without development --path vendor/bundle

COPY . /usr/src/app
RUN rm -f /usr/src/app/config/database.yml
RUN rm -f /usr/src/app/config/secrets.yml
COPY ./config/database.docker.yml /usr/src/app/config/database.yml
COPY ./config/secrets.docker.yml /usr/src/app/config/secrets.yml

RUN RAILS_ENV=production DEVISE_SECRET=dummy bundle exec rake i18n:js:export

ENV POSTGRESQL_ADDRESS = '192.168.99.100' \
    POSTGRESQL_PORT = '5432' \
    POSTGRESQL_USERNAME = 'argu' \
    POSTGRESQL_PASSWORD = '' \
    POSTGRESQL_DATABASE = 'argu_production' \
    RAILS_ENV = 'production' \
    REDIS_ADDRESS = '192.168.99.100' \
    REDIS_PORT = '6379' \
    SECRET_KEY_BASE = '' \
    SECRET_KEY = '' \
    DEVISE_SECRET = '' \
    DEVISE_PEPPER = '' \
    JWT_ENCRYPTION_TOKEN = '' \
    FACEBOOK_KEY = '' \
    FACEBOOK_SECRET = '' \
    FRESHDESK_SECRET = '' \
    FRESHDESK_URL = '' \
    MAILGUN_API_TOKEN = '' \
    MAILGUN_DOMAIN = '' \
    MAILGUN_SENDER = '' \
    OPENCAGE_GEOCODER_KEY = '' \
    AWS_ID = '' \
    AWS_KEY = '' \
    FRESHDESK_SECRET = ''

RUN npm install -g yarn
RUN yarn

ARG FRONTEND_HOSTNAME
RUN yarn run build:production

RUN bundle exec rake RAILS_ENV=production ASSET_HOST=$ASSET_HOST DEVISE_SECRET=dummy assets:precompile

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
