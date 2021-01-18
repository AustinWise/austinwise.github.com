#!/bin/sh
set -e
rm Gemfile.lock
bundle config build.nokogiri --use-system-libraries
bundle install
echo SUCCESS
