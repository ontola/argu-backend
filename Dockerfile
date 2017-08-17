FROM argu/alpine-vips as vips-alpine

# Build env
FROM argu/alpine-v8 as build-env
ARG ASSET_HOST

RUN apk --update add linux-headers git openssh-client build-base nodejs nodejs-npm \
  postgresql-dev libffi-dev libxml2 libxml2-dev libxslt libxslt-dev libwebp-dev qt-dev gobject-introspection-dev
RUN apk add vips-dev --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/

RUN gem install --install-dir vendor/bundle /root/pkg/libv8-5.9.211.38.1-x86_64-linux.gem
RUN RAILS_ENV=production bundle install --frozen --clean --without development test --path vendor/bundle

ENV POSTGRESQL_ADDRESS='192.168.99.100' \
  POSTGRESQL_PORT='5432' \
  POSTGRESQL_USERNAME='argu' \
  POSTGRESQL_PASSWORD='' \
  POSTGRESQL_DATABASE='argu_production' \
  EREDIS_ADDRESS='192.168.99.100' \
  REDIS_PORT='6379' \
  SECRET_KEY_BASE='' \
  SECRET_KEY='' \
  DEVISE_SECRET='' \
  DEVISE_PEPPER='' \
  JWT_ENCRYPTION_TOKEN='' \
  FACEBOOK_KEY='' \
  FACEBOOK_SECRET='' \
  FRESHDESK_SECRET='' \
  FRESHDESK_URL='' \
  MAILGUN_API_TOKEN='' \
  MAILGUN_DOMAIN='' \
  MAILGUN_SENDER='' \
  OPENCAGE_GEOCODER_KEY='' \
  AWS_ID='' \
  AWS_KEY='' \
  FRESHDESK_SECRET=''

COPY ./package.json .
RUN npm install -g yarn
RUN yarn

COPY --from=vips-alpine /usr/lib/girepository-1.0/Vips-8.0.typelib /usr/lib/girepository-1.0/Vips-8.0.typelib

RUN mkdir -p /usr/src/app/log
COPY . /usr/src/app
RUN rm -f /usr/src/app/config/database.yml /usr/src/app/config/secrets.yml
COPY ./config/database.docker.yml /usr/src/app/config/database.yml
COPY ./config/secrets.docker.yml /usr/src/app/config/secrets.yml

RUN RAILS_ENV=production DEVISE_SECRET=dummy bundle exec rake i18n:js:export
RUN yarn run build:production
RUN bundle exec rake RAILS_ENV=production ASSET_HOST=$ASSET_HOST DEVISE_SECRET=dummy assets:precompile

RUN apk del linux-headers git openssh-client build-base nodejs-npm llvm4-libs qt-dev
RUN find ./node_modules -not -name 'turbolinks.js' -delete
RUN rm -rf /var/cache/apk/* /tmp/* /usr/lib/python2.7 /usr/lib/node_modules /root/.bundle /root/.npm /root/.gem /usr/local/share/.cache

# Final image
FROM ruby:2.4.1-alpine3.6
COPY --from=build-env / /
EXPOSE 3000
WORKDIR /usr/src/app
CMD ["rails", "server", "-b", "0.0.0.0"]
