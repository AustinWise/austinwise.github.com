#!/bin/sh
cd $(dirname "$(readlink -f "$0")")
bundle exec jekyll serve
