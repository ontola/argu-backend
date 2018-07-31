FROM fletcher91/ruby-vips-qt-unicorn:2.4.1

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

ADD package.json /usr/src/app/
ADD yarn.lock /usr/src/app/

RUN npm install -g yarn
RUN yarn

COPY . /usr/src/app
RUN rm -f /usr/src/app/config/database.yml
RUN rm -f /usr/src/app/config/secrets.yml
COPY ./config/database.docker.yml /usr/src/app/config/database.yml
COPY ./config/secrets.docker.yml /usr/src/app/config/secrets.yml

RUN RAILS_ENV=production SECRET_KEY_BASE=dummy DEVISE_SECRET=dummy bundle exec rake i18n:js:export

ARG HOSTNAME

ENV HOSTNAME $HOSTNAME
ENV ASSET_HOST $HOSTNAME
ENV FRONTEND_HOSTNAME $HOSTNAME
ENV OAUTH_URL "https://$HOSTNAME"
ENV ARGU_API_URL "https://$HOSTNAME"

RUN yarn run build:production

RUN bundle exec rake RAILS_ENV=production SECRET_KEY_BASE=dummy DEVISE_SECRET=dummy assets:precompile

ARG RAILS_ENV=production
ENV RAILS_ENV $RAILS_ENV

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
