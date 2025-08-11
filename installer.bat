@echo off
setlocal

:: === Variables ===
set BASE_DIR=C:\reel-transcriber
set ASSETS_DIR=%BASE_DIR%\assets
set PY_DIR=%BASE_DIR%\python
set DOCS_DIR=%USERPROFILE%\Documents\Transcribed Reels
set SHORTCUT_NAME=Reel Transcriber.lnk
set ICON_FILE=%ASSETS_DIR%\icon.ico

echo === Reel Transcriber Installer ===

:: Create base folders
mkdir "%BASE_DIR%" >nul 2>&1
mkdir "%ASSETS_DIR%" >nul 2>&1
mkdir "%DOCS_DIR%" >nul 2>&1

:: Download portable Python
echo Downloading Portable Python 3.11...
powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip -OutFile %BASE_DIR%\python.zip"

:: Extract portable Python
powershell -Command "Expand-Archive -Path %BASE_DIR%\python.zip -DestinationPath %PY_DIR%"
del "%BASE_DIR%\python.zip"

:: Download FFmpeg
echo Downloading FFmpeg...
powershell -Command "Invoke-WebRequest -Uri https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip -OutFile %BASE_DIR%\ffmpeg.zip"
powershell -Command "Expand-Archive -Path %BASE_DIR%\ffmpeg.zip -DestinationPath %BASE_DIR%\ffmpeg"
del "%BASE_DIR%\ffmpeg.zip"

:: Install Python dependencies
echo Installing dependencies...
"%PY_DIR%\python.exe" -m ensurepip
"%PY_DIR%\python.exe" -m pip install --upgrade pip setuptools wheel
"%PY_DIR%\python.exe" -m pip install yt-dlp opencv-python pytesseract pillow git+https://github.com/openai/whisper.git

:: Copy icon file (make sure it's in assets folder before running installer)
if exist "%ICON_FILE%" (
    echo Icon found: %ICON_FILE%
) else (
    echo ⚠ icon.ico not found in %ASSETS_DIR%
)

:: Create run.bat in BASE_DIR
(
echo @echo off
echo set BASE_DIR=%BASE_DIR%
echo set PY_DIR=%%BASE_DIR%%\python
echo set DOCS_DIR=%%USERPROFILE%%\Documents\Transcribed Reels
echo set COOKIES_FILE=%%USERPROFILE%%\Downloads\cookies.txt
echo set SCRIPT_PATH=%%BASE_DIR%%\reel_transcriber_vad.py
echo.
echo if not exist "%%COOKIES_FILE%%" (
echo     echo ⚠ cookies.txt not found in Downloads!
echo     pause
echo     exit /b
echo )
echo "%%PY_DIR%%\python.exe" "%%SCRIPT_PATH%%"
echo pause
) > "%BASE_DIR%\run.bat"

:: Create desktop shortcut with icon
echo Creating desktop shortcut...
powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('$env:USERPROFILE\Desktop\%SHORTCUT_NAME%');$s.TargetPath='%BASE_DIR%\run.bat';$s.IconLocation='%ICON_FILE%';$s.Save()"

echo.
echo ✅ Installation complete!
pause
