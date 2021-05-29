# Match Ruby version from here: https://pages.github.com/versions/
FROM netlify/build:focal

# TODO: figure out how to not run this all as root
USER root

WORKDIR /app
