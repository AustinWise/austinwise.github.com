# How to build

[![Netlify Status](https://api.netlify.com/api/v1/badges/ff3f28b6-3f4d-452f-9bb1-6d60e1c1faad/deploy-status)](https://app.netlify.com/projects/austinwise/deploys)

This site is built with
[Cobalt](https://cobalt-org.github.io/)
and deployed on Netlify.

There are some of scripts:

* build.sh: the build script invoked by Netlify to build the site
* serve.sh: serve the site
* serve.cmd: serve the site *on Windows*

# Building in Docker

 Even though Cobalt is easy to run outside a container,
there are some scripts for running Cobalt inside the
[Netlify Docker image](https://hub.docker.com/r/netlify/build)
to make sure it works as intended. There are scripts to start the Docker container
from Linux and Windows:

* serve_docker.cmd
* serve_docker.sh

# Updating personal picture

Install ImageMagick and libheif plugins:

```bash
sudo apt install imagemagick-7.q16hdri libheif-plugins-all
```

Create a 400 x 400 PNG file (todo: why this size? what about high DPI).
Then use that as the source to create different image formats:

```bash
magick Me.VX.png Me.V4.jpeg
magick Me.VX.png Me.V4.avif
# ...
```

The search for "Me.V" in this repo and update references.

Currently the favicon is 32x32 pixels and PNG.

# Why Netlify and not GitHub Pages?

I honestly cannot remember...
