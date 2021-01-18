#!/bin/sh
cd $(dirname "$(readlink -f "$0")")
bundle exec jekyll serve -P 4000 --livereload --livereload-port 4001
