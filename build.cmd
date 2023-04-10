@echo off
setlocal

cd %~dp0

PowerShell -NoProfile -NonInteractive -File build.ps1 %*
