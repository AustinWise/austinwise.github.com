@echo off
setlocal
cd %~dp0

docker build -t austinweb .
docker run -it --rm -p 4000:4000 -v %CD%:/app austinweb
