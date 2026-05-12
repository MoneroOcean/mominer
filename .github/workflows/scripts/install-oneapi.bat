@echo off
setlocal
set URL=%~1
set COMPONENTS=%~2
set PACKAGE=%~3

if "%PACKAGE%"=="" (
  echo Package name is required.
  exit /b 1
)
for /f "delims=" %%U in ('powershell -NoProfile -ExecutionPolicy Bypass -File .github\workflows\scripts\resolve-oneapi-url.ps1 "%URL%" "%PACKAGE%"') do set URL=%%U

curl.exe --output "%TEMP%\oneapi-webimage.exe" --url "%URL%" --retry 5 --retry-delay 5
start /b /wait "%TEMP%\oneapi-webimage.exe" -s -x -f oneapi_webimage_extracted --log extract.log
del "%TEMP%\oneapi-webimage.exe"

oneapi_webimage_extracted\bootstrapper.exe -s --action install --components=%COMPONENTS% --eula=accept --log-dir=.
set INSTALLER_EXIT_CODE=%ERRORLEVEL%

rd /s /q oneapi_webimage_extracted
exit /b %INSTALLER_EXIT_CODE%
