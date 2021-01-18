# Match Ruby version from here: https://pages.github.com/versions/
FROM ruby:2.7.1-buster

ADD ./Gemfile /app/Gemfile
ADD ./Gemfile.lock /app/Gemfile.lock

WORKDIR /app

RUN bundle config build.nokogiri --use-system-libraries && bundle install

