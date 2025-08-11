@echo off
title Reel Transcriber Installer
color 0A
setlocal

set BASE_DIR=C:\reel-transcriber
set PY_DIR=%BASE_DIR%\python
set FF_DIR=%BASE_DIR%\ffmpeg
set ASSETS_DIR=%BASE_DIR%\assets
set SCRIPT_PATH=%BASE_DIR%\scripts\reel_transcriber_vad.py
set ICON_PATH=%ASSETS_DIR%\icon.ico
set SHORTCUT_NAME=Reel Transcriber.lnk
set DESKTOP_PATH=%USERPROFILE%\Desktop

echo === Reel Transcriber Installer ===

:: Create base directories
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%ASSETS_DIR%" mkdir "%ASSETS_DIR%"
if not exist "%BASE_DIR%\scripts" mkdir "%BASE_DIR%\scripts"

:: STEP 1 - Download Portable Python
if not exist "%PY_DIR%" (
    echo ▓ Downloading Portable Python 3.11.9...
    powershell -Command "Invoke-WebRequest -Uri https://github.com/winpython/winpython/releases/download/20240602/Winpython64-3.11.9.0dot.exe -OutFile %BASE_DIR%\python_installer.exe"
    echo ▓ Extracting Python...
    "%BASE_DIR%\python_installer.exe" -y -o"%PY_DIR%"
    del "%BASE_DIR%\python_installer.exe"
)

:: STEP 2 - Install pip via get-pip.py
if not exist "%PY_DIR%\Scripts\pip.exe" (
    echo ▓ Downloading get-pip.py...
    powershell -Command "Invoke-WebRequest -Uri https://bootstrap.pypa.io/get-pip.py -OutFile %BASE_DIR%\get-pip.py"
    echo ▓ Installing pip...
    "%PY_DIR%\python.exe" "%BASE_DIR%\get-pip.py"
    del "%BASE_DIR%\get-pip.py"
)

:: STEP 3 - Install dependencies
echo ▓ Installing Python dependencies...
"%PY_DIR%\python.exe" -m pip install --upgrade pip
"%PY_DIR%\python.exe" -m pip install yt-dlp openai-whisper opencv-python pytesseract pillow torch tiktoken

:: STEP 4 - Download FFmpeg
if not exist "%FF_DIR%" (
    echo ▓ Downloading FFmpeg...
    powershell -Command "Invoke-WebRequest -Uri https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip -OutFile %BASE_DIR%\ffmpeg.zip"
    echo ▓ Extracting FFmpeg...
    powershell -Command "Expand-Archive -Path '%BASE_DIR%\ffmpeg.zip' -DestinationPath '%BASE_DIR%'"
    for /d %%i in ("%BASE_DIR%\ffmpeg-*") do move "%%i\bin" "%FF_DIR%"
    rmdir /s /q "%BASE_DIR%\ffmpeg-*"
    del "%BASE_DIR%\ffmpeg.zip"
)

:: STEP 5 - Chrome extension info (bright cyan)
color 0B
echo.
echo ============================================================
echo Please install the "Get cookies.txt" Chrome extension:
echo https://chrome.google.com/webstore/detail/get-cookiestxt/iaiioopjkcekapmldfgbebdclcnpgnlo
echo.
echo 1. Open Chrome and log into Instagram.
echo 2. Use the extension to export cookies.txt to your Downloads folder.
echo ============================================================
color 0A
echo.

:: STEP 6 - Create desktop shortcut
echo ▓ Creating desktop shortcut...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%DESKTOP_PATH%\%SHORTCUT_NAME%');$s.TargetPath='%BASE_DIR%\run.bat';$s.IconLocation='%ICON_PATH%';$s.WorkingDirectory='%BASE_DIR%';$s.Save()"

echo ▓ Installation complete! You can now run Reel Transcriber from your desktop.
pause
