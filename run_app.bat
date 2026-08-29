@echo off
TITLE Maza Pandurang - Flutter Web App
SETLOCAL EnableDelayedExpansion
SET "PATH=S:\Softwares\flutter\bin;%PATH%"
CD /D "%~dp0"

SET "KEY_FOUND="

IF NOT "%MAPTILER_API_KEY%"=="" (
    SET "KEY_FOUND=%MAPTILER_API_KEY%"
) ELSE IF EXIST "maptiler.key" (
    FOR /F "usebackq tokens=*" %%K IN ("maptiler.key") DO SET "KEY_FOUND=%%K"
) ELSE IF EXIST ".env" (
    FOR /F "usebackq tokens=*" %%K IN (`findstr /B "MAPTILER_API_KEY=" .env`) DO (
        FOR /F "tokens=2 delims==" %%V IN ("%%K") DO SET "KEY_FOUND=%%V"
    )
)

echo Launching Maza Pandurang on Chrome...
IF NOT "!KEY_FOUND!"=="" (
    echo MapTiler API Key detected.
    flutter run -d chrome --dart-define=MAPTILER_API_KEY=!KEY_FOUND!
) ELSE (
    echo MapTiler API Key not set. Running with fallback canvas...
    flutter run -d chrome
)
pause
