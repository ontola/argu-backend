FROM fletcher91/ruby-vips-qt-unicorn:latest

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
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

ENV ARGU_DB_HOST '192.168.99.100'
ENV ARGU_DB_PORT '5432'
ENV ARGU_DB_USER 'argu'
ENV ARGU_DB_PASS ''
ENV ARGU_DB_NAME 'argu'
ENV RAILS_ENV 'production'
ENV ARGU_REDIS_HOST '192.168.99.100'
ENV ARGU_REDIS_PORT '6379'

RUN npm install
RUN npm run build:production

RUN bundle exec rake RAILS_ENV=production DEVISE_SECRET=dummythatshouldbelongenoughtoletdevisebeleiveitsanactualtoken assets:precompile
VOLUME ["/usr/src/app/public"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
