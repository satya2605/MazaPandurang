@echo off
TITLE Maza Pandurang - Flutter Launcher
SETLOCAL

:: Ensure Flutter SDK is in PATH
SET "PATH=S:\Softwares\flutter\bin;%PATH%"

:: Navigate to project directory
CD /D "%~dp0"

echo ========================================================
echo   🚩 Maza Pandurang (माझा पांडुरंग) - Application Launcher
echo ========================================================
echo.
echo Select target device to run/reload application:
echo  [1] Chrome Web (Recommended - Quick Dev Reload)
echo  [2] Windows Desktop App
echo  [3] Edge Web
echo.

SET /P Choice="Enter choice (1, 2, or 3, default is 1): "
IF "%Choice%"=="2" GOTO RUN_WINDOWS
IF "%Choice%"=="3" GOTO RUN_EDGE

:RUN_CHROME
echo.
echo Launching Maza Pandurang on Chrome Web...
flutter run -d chrome
GOTO END

:RUN_WINDOWS
echo.
echo Launching Maza Pandurang on Windows Desktop...
flutter run -d windows
GOTO END

:RUN_EDGE
echo.
echo Launching Maza Pandurang on Edge Web...
flutter run -d edge
GOTO END

:END
pause
