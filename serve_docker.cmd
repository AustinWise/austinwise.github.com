@echo off
setlocal
cd /d %~dp0

REM Must run as root, as the mounted volume is owned by root.
docker run -it --rm -p 1024:1024 -v %CD%:/app -u root netlify/build:noble /app/serve.sh --host 0.0.0.0
