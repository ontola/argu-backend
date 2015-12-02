FROM ruby:2.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev libvips-dev libgsf-1-dev libxml2 zlib1g-dev qt5-default libqt5webkit5-dev unicorn
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app
RUN unlink /usr/src/app/config/database.yml
COPY ./config/database.docker.yml /usr/src/app/config/database.yml

ENV ARGU_DB_HOST '192.168.99.100'
ENV ARGU_DB_PORT '5432'
ENV ARGU_DB_USER 'argu'
ENV ARGU_DB_PASS ''
ENV ARGU_DB_NAME 'argu'
ENV RAILS_ENV 'production'
ENV REDIS_HOST '192.168.99.100'
ENV REDIS_PORT '6379'


EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
