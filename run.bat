@echo off
setlocal

set BASE_DIR=C:\reel-transcriber
set PY_DIR=%BASE_DIR%\python
set DOCS_DIR=%USERPROFILE%\Documents\Reel Transcriptions
set COOKIES_FILE=%USERPROFILE%\Downloads\cookies.txt
set SCRIPT_PATH=%BASE_DIR%\scripts\reel_transcriber_vad.py

echo === Reel Transcriber Runner ===

if not exist "%COOKIES_FILE%" (
    echo ⚠ cookies.txt not found in Downloads!
    echo.
    echo 1. Open Chrome and log into Instagram.
    echo 2. Use the cookies.txt extension (installed earlier) to export it.
    echo 3. Save the file as cookies.txt in your Downloads folder.
    pause
    exit /b
)

echo Running Reel Transcriber...
"%PY_DIR%\python.exe" "%SCRIPT_PATH%"
echo.
echo ✅ Finished! Check %DOCS_DIR% for your transcripts.
pause

