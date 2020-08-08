FROM ruby:2.7-buster

ADD ./Gemfile /app/Gemfile
ADD ./Gemfile.lock /app/Gemfile.lock

WORKDIR /app

RUN bundle config build.nokogiri --use-system-libraries && bundle install

ENTRYPOINT [ "bundle", "exec", "jekyll", "serve", "--host=0.0.0.0" ]
