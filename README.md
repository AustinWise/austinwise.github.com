# How to build

In ubuntu 20.04:

```bash
sudo apt install ruby ruby-dev ruby-bundler libxml2-dev libxslt1-dev
bundle config build.nokogiri --use-system-libraries
bundle install
bundle exec jekyll server
```

## Updating the version of everything

```bash
rm Gemfile.lock
bundle install
```

## Building with docker

Run serve_docker.cmd. The `--watch` argument does not seem to work for
`jekyll serve` when running in a container.
