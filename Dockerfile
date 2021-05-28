# Match Ruby version from here: https://pages.github.com/versions/
FROM netlify/build:focal

# TODO: figure out how to not run this all as root
USER root

ADD ./Gemfile /app/Gemfile
ADD ./Gemfile.lock /app/Gemfile.lock

WORKDIR /app

# TODO: figure out if there is a better way to invoke ruby from this image
RUN bash -c "source /opt/buildhome/.rvm/scripts/rvm && rvm use && bundle config build.nokogiri --use-system-libraries && bundle install"
