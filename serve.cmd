@echo off
setlocal
cd /d %~dp0

PowerShell -NoProfile -NonInteractive -File serve.ps1 %*
