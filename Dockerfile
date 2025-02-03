FROM ruby:3.1.4 AS base
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs npm libvips
RUN npm install -g yarn && \
    yarn install
RUN mkdir /webapp
WORKDIR /webapp

FROM base AS bundler
COPY Gemfile /webapp/Gemfile
COPY Gemfile.lock /webapp/Gemfile.lock
RUN bundle install

FROM bundler AS packaged
COPY . /webapp/
RUN npm install -g yarn && yarn install && yarn build

FROM bundler as development
RUN gem install foreman
EXPOSE 3000
CMD ["bin/dev"]