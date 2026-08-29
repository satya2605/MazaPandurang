@echo off
TITLE Maza Pandurang - Flutter Web App
SET "PATH=S:\Softwares\flutter\bin;%PATH%"
CD /D "%~dp0"
echo Launching Maza Pandurang on Chrome...
IF DEFINED MAPTILER_API_KEY (
    flutter run -d chrome --dart-define=MAPTILER_API_KEY=%MAPTILER_API_KEY%
) ELSE (
    flutter run -d chrome
)
pause
