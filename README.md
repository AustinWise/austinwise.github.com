# How to build

[![Netlify Status](https://api.netlify.com/api/v1/badges/ff3f28b6-3f4d-452f-9bb1-6d60e1c1faad/deploy-status)](https://app.netlify.com/sites/austinwise/deploys)

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
[Netlify Docker image](https://github.com/netlify/build-image/blob/focal/Dockerfile)
to make sure it works as intended. There are scripts to start the Docker container
from Linux and Windows:

* serve_docker.cmd
* serve_docker.sh

# Custom build of Cobalt

Currently there are some small bugs in Cobalt:

https://github.com/AustinWise/cobalt.rs

# Why not GitHub Pages?

Seriously, that would be quite a bit simpler. But I tried to upload a large HTML
file and it was not showing up on my website.
