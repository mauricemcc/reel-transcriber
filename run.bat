@echo off
title Reel Transcriber
color 0F
echo === Reel Transcriber ===
setlocal ENABLEDELAYEDEXPANSION

set BASE_DIR=C:\reel-transcriber
set PY_DIR=%BASE_DIR%\python
set SCRIPT_PATH=%BASE_DIR%\scripts\reel_transcriber_vad.py
set DOCS_DIR=%USERPROFILE%\Documents\Transcribed Reels
set COOKIES_FILE=%USERPROFILE%\Downloads\cookies.txt
set FF_DIR=%BASE_DIR%\ffmpeg

:: 1. Check for Python
if not exist "%PY_DIR%\python.exe" (
    echo [ERROR] Python not found in %PY_DIR%.
    pause
    exit /b
)

:: 2. Check pip
"%PY_DIR%\python.exe" -m pip --version >nul 2>&1
if errorlevel 1 (
    echo ╠ Installing pip...
    "%PY_DIR%\python.exe" -m ensurepip
    "%PY_DIR%\python.exe" -m pip install --upgrade pip setuptools wheel
)

:: 3. Check dependencies
echo Checking dependencies...
"%PY_DIR%\python.exe" -m pip show yt-dlp >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show openai-whisper >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show opencv-python >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show pytesseract >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show pillow >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show torch >nul 2>&1 || set MISSING_DEPS=1
"%PY_DIR%\python.exe" -m pip show tiktoken >nul 2>&1 || set MISSING_DEPS=1

if defined MISSING_DEPS (
    echo ╠ Installing missing dependencies...
    "%PY_DIR%\python.exe" -m pip install yt-dlp openai-whisper opencv-python pytesseract pillow torch tiktoken
)

:: 4. Check FFmpeg
if not exist "%FF_DIR%\bin\ffmpeg.exe" (
    echo [ERROR] FFmpeg not found in %FF_DIR%\bin.
    echo Please run the installer again.
    pause
    exit /b
)

:: 5. Check cookies.txt
if not exist "%COOKIES_FILE%" (
    color 0B
    echo ============================================================
    echo [!] cookies.txt not found in Downloads!
    echo Please install the "Get cookies.txt" Chrome extension:
    echo https://chrome.google.com/webstore/detail/get-cookiestxt/iaiioopjkcekapmldfgbebdclcnpgnlo
    echo.
    echo Then log into Instagram and export cookies.txt to Downloads.
    echo ============================================================
    color 0F
    pause
    exit /b
)

:: 6. Run the script
echo ╠ Running Reel Transcriber...
"%PY_DIR%\python.exe" "%SCRIPT_PATH%"
echo.
echo ╚ Finished! Check "%DOCS_DIR%" for your transcripts.
pause
