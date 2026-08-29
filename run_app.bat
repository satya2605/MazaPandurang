@echo off
TITLE Maza Pandurang - Flutter Web App
SET "PATH=S:\Softwares\flutter\bin;%PATH%"
CD /D "%~dp0"
echo Launching Maza Pandurang on Chrome...
flutter run -d chrome
pause
