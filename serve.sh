#!/bin/bash
source /opt/buildhome/.rvm/scripts/rvm
rvm use
# the --force_polling is for running in WSL
bundle exec jekyll serve --host=0.0.0.0 --force_polling -P 4000 --livereload --livereload-port 4001
