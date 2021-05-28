@echo off
setlocal
cd %~dp0

docker build -t austinweb .
if ERRORLEVEL 1 (EXIT /b 1)
docker run -it --rm -v %CD%:/app austinweb "/app/update_deps.sh"
