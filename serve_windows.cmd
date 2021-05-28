@echo off
setlocal
cd %~dp0

docker build -t austinweb .
if ERRORLEVEL 1 (EXIT /b 1)
docker run -it --rm -p 4000:4000 -p 4001:4001 -v %CD%:/app austinweb /app/serve.sh
