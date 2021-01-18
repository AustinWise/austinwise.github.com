@echo off
setlocal
cd %~dp0

docker build -t austinweb .
if ERRORLEVEL 1 (EXIT /b 1)
docker run -it --rm -p 4000:4000 -v %CD%:/app austinweb bundle exec jekyll serve --host=0.0.0.0 --force_polling
