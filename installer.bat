@echo off
setlocal EnableDelayedExpansion
title Reel Transcriber Installer

set BASE_DIR=C:\reel-transcriber
set PY_DIR=%BASE_DIR%\python
set PY_URL=https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip
set PY_ZIP=%BASE_DIR%\python.zip
set GETPIP_URL=https://bootstrap.pypa.io/get-pip.py
set FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
set FFMPEG_ZIP=%BASE_DIR%\ffmpeg.zip
set DOCS_DIR=%USERPROFILE%\Documents\Transcribed Reels

echo === Reel Transcriber Installer ===

:: Create base folder
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%"
if not exist "%DOCS_DIR%" mkdir "%DOCS_DIR%"

:: Download Python ZIP
echo ► Downloading Portable Python 3.11.9...
powershell -Command "Invoke-WebRequest -Uri '%PY_URL%' -OutFile '%PY_ZIP%'"
if errorlevel 1 (
    echo [ERROR] Failed to download Python.
    pause
    exit /b
)

:: Extract Python ZIP
echo ► Extracting Python...
powershell -Command "Expand-Archive -Path '%PY_ZIP%' -DestinationPath '%PY_DIR%' -Force"
del "%PY_ZIP%"

:: Download get-pip.py
echo ► Downloading get-pip.py...
powershell -Command "Invoke-WebRequest -Uri '%GETPIP_URL%' -OutFile '%BASE_DIR%\get-pip.py'"

:: Install pip
echo ► Installing pip...
"%PY_DIR%\python.exe" "%BASE_DIR%\get-pip.py"

:: Install dependencies
echo ► Installing Python dependencies...
"%PY_DIR%\python.exe" -m pip install --upgrade pip
"%PY_DIR%\python.exe" -m pip install yt-dlp openai-whisper opencv-python pytesseract pillow torch tiktoken

:: Download FFmpeg
echo ► Downloading FFmpeg...
powershell -Command "Invoke-WebRequest -Uri '%FFMPEG_URL%' -OutFile '%FFMPEG_ZIP%'"
echo ► Extracting FFmpeg...
powershell -Command "Expand-Archive -Path '%FFMPEG_ZIP%' -DestinationPath '%BASE_DIR%' -Force"
del "%FFMPEG_ZIP%"
move "%BASE_DIR%\ffmpeg-*-essentials_build" "%BASE_DIR%\ffmpeg" >nul

:: Show Chrome extension step in cyan
echo.
echo ============================================================
echo [96mPlease install the "Get cookies.txt" Chrome extension:[0m
echo [96mhttps://chrome.google.com/webstore/detail/get-cookiestxt/iaiioopjkcekapmldfgbebdclcnpgnlo[0m
echo.
echo 1. Open Chrome and log into Instagram.
echo 2. Use the extension to export cookies.txt to your Downloads folder.
echo ============================================================
echo.

:: Create desktop shortcut
echo ► Creating desktop shortcut...
set SHORTCUT_PATH=%USERPROFILE%\Desktop\Reel Transcriber.lnk
powershell -Command ^
  "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT_PATH%');" ^
  "$s.TargetPath='%BASE_DIR%\run.bat';" ^
  "$s.IconLocation='%BASE_DIR%\assets\icon.ico';" ^
  "$s.WorkingDirectory='%BASE_DIR%';" ^
  "$s.Save()"

echo.
echo ✔ Installation complete! You can now run Reel Transcriber from your desktop.
pause
