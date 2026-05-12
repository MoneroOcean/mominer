@echo off
setlocal

set "URL=%~1"
set "COMPONENTS=%~2"
set "PACKAGE=%~3"
set "SCRIPT_DIR=%~dp0"
set "URL_FILE=%TEMP%\oneapi-url.txt"
set "INSTALLER=%TEMP%\oneapi-installer.exe"
set "EXTRACT_DIR=oneapi_webimage_extracted"

if "%PACKAGE%"=="" (
  echo Package name is required.
  exit /b 1
)

if "%URL%"=="" (
  echo Intel oneAPI URL or URL source is required.
  exit /b 1
)

del "%URL_FILE%" >nul 2>nul

powershell -NoProfile -ExecutionPolicy Bypass ^
  -File "%SCRIPT_DIR%resolve-oneapi-url.ps1" "%URL%" "%PACKAGE%" > "%URL_FILE%"

if errorlevel 1 (
  echo Failed to resolve Intel oneAPI installer URL.
  exit /b 1
)

set /p URL=<"%URL_FILE%"
del "%URL_FILE%" >nul 2>nul

if "%URL%"=="" (
  echo Resolved Intel oneAPI installer URL is empty.
  exit /b 1
)

echo Using Intel oneAPI installer URL:
echo %URL%

curl.exe --fail --location --show-error --retry 5 --retry-delay 5 ^
  --output "%INSTALLER%" ^
  --url "%URL%"

if errorlevel 1 (
  echo Failed to download Intel oneAPI installer.
  exit /b 1
)

if not exist "%INSTALLER%" (
  echo Intel oneAPI installer was not downloaded.
  exit /b 1
)

for %%A in ("%INSTALLER%") do set "INSTALLER_SIZE=%%~zA"

if not defined INSTALLER_SIZE (
  echo Could not determine Intel oneAPI installer size.
  exit /b 1
)

if %INSTALLER_SIZE% LSS 10000000 (
  echo Downloaded Intel oneAPI installer is suspiciously small: %INSTALLER_SIZE% bytes.
  echo This usually means an HTML error page was downloaded instead of the installer.
  del "%INSTALLER%" >nul 2>nul
  exit /b 1
)

rd /s /q "%EXTRACT_DIR%" >nul 2>nul

start "" /b /wait "%INSTALLER%" -s -x -f "%EXTRACT_DIR%" --log extract.log
set "EXTRACT_EXIT_CODE=%ERRORLEVEL%"

del "%INSTALLER%" >nul 2>nul

if not "%EXTRACT_EXIT_CODE%"=="0" (
  echo Intel oneAPI installer extraction failed with exit code %EXTRACT_EXIT_CODE%.
  exit /b %EXTRACT_EXIT_CODE%
)

if not exist "%EXTRACT_DIR%\bootstrapper.exe" (
  echo Intel oneAPI bootstrapper.exe was not found after extraction.
  exit /b 1
)

"%EXTRACT_DIR%\bootstrapper.exe" -s --action install --components=%COMPONENTS% --eula=accept --log-dir=.
set "INSTALLER_EXIT_CODE=%ERRORLEVEL%"

rd /s /q "%EXTRACT_DIR%" >nul 2>nul

exit /b %INSTALLER_EXIT_CODE%
