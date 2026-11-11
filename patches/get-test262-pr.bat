@echo off
setlocal

if "%~2"=="" (
  echo Usage: %~nx0 PR_NUMBER V8_CHECKOUT
  echo Example: %~nx0 1234 C:\src\v8
  exit /b 1
)

set "PR=%~1"
set "DEST=%~2\test\test262\local-tests"
set "API=https://api.github.com/repos/tc39/test262/pulls/%PR%/files?per_page=100"

> "%TEMP%\test262-filter.jq" echo .[] ^| [.filename, .raw_url] ^| join^("|"^)

type nul > "%TEMP%\test262-pr-files.txt"
set "PAGE=1"

:fetch_page
set "API=https://api.github.com/repos/tc39/test262/pulls/%PR%/files?per_page=100&page=%PAGE%"

curl -fsSL "%API%" -o "%TEMP%\test262-pr-files.json"
if errorlevel 1 (
  echo Failed to retrieve PR file list.
  exit /b 1
)

for /f %%C in ('jq length "%TEMP%\test262-pr-files.json"') do set "COUNT=%%C"

if "%COUNT%"=="0" goto files_ready

jq -r -f "%TEMP%\test262-filter.jq" "%TEMP%\test262-pr-files.json" >> "%TEMP%\test262-pr-files.txt"
if errorlevel 1 (
  echo Failed to retrieve PR file list. Check that curl and jq are installed.
  exit /b 1
)

if %COUNT% LSS 100 goto files_ready
set /a PAGE+=1
goto fetch_page

:files_ready
for /f "usebackq tokens=1,2 delims=|" %%A in ("%TEMP%\test262-pr-files.txt") do (
  for %%D in ("%DEST%\%%A") do if not exist "%%~dpD" mkdir "%%~dpD"
  curl -fsSL "%%B" -o "%DEST%\%%A"
  if errorlevel 1 (
    echo Failed to download %%A
    exit /b 1
  )
  echo Downloaded %%A
)

del "%TEMP%\test262-pr-files.txt"

