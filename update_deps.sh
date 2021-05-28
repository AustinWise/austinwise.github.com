#!/bin/bash

source /opt/buildhome/.rvm/scripts/rvm
rvm use

set -e

rm Gemfile.lock
bundle config build.nokogiri --use-system-libraries
bundle install

echo SUCCESS
