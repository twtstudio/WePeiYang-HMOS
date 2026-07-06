@echo off
setlocal

if not defined PUB_CACHE set "PUB_CACHE=D:\pub-cache"

cd /d "%~dp0"
flutter build har --debug
exit /b %ERRORLEVEL%
