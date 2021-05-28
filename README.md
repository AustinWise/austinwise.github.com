# How to build

[![Netlify Status](https://api.netlify.com/api/v1/badges/ff3f28b6-3f4d-452f-9bb1-6d60e1c1faad/deploy-status)](https://app.netlify.com/sites/austinwise/deploys)

This site is built with Jekyll and deployed on Netlify. Therefore building is done
on top of the
[Netlify Docker image](https://github.com/netlify/build-image/blob/focal/Dockerfile).
To keep things speedy when testing locally, I build a Docker image on top of
this with all the Ruby gems installed.

There are two types of scripts:

* serve: build the docker image and serve the site
* update_deps: update the dependancy versions in Gemfile.lock

Each of these has two entry points:

* _linux.sh: runs from Linux
* _windows.cmd: runs from Windows

# Why not GitHub Pages?

Seriously, that would be quite a bit simpler. But I tried to upload a large HTML
file and it was not showing up on my website.
