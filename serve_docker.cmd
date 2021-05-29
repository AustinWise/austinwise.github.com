@echo off
setlocal
cd %~dp0

REM Must run as root, as the mounted volume is owned by root.
docker run -it --rm -p 3000:3000 -v %CD%:/app -u root netlify/build:focal /app/serve.sh
