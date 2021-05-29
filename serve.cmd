@echo off
setlocal
cd %~dp0

PowerShell -NoProfile -NonInteractive -File serve.ps1
