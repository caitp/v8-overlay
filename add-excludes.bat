@echo off
setlocal
setlocal EnableDelayedExpansion
set "V8="
set "ARG=%~1"
set "EXCLUDE_FILES=%TEMP%\overlay-paths-%RANDOM%-%RANDOM%.tmp"
set "OVERLAY_DIR=%~dp0v8"
rem In order to avoid putting CRLF in .git/info/exclude, define a linefeed with EnableDelayedExpansion
set LF=^


rem The blank lines are part of the LF definition, do not remove!
if defined ARG (
    if /i "%ARG:~0,5%"=="--v8=" (
        set "V8=%ARG:~5%"
    ) else (
        set "V8=%ARG%"
    )
)
if not defined V8 goto :promptV8
goto :collectExcludes

:promptV8
set /p "V8=V8 repository path [%CD%]: "
if not defined V8 set "V8=%CD%"
set /p "OK=Using %V8%. Is this okay? [Y/n]"
if /i "%OK%"=="n" (exit /b 1) else if /i "%OK%"=="no" exit /b 1

:collectExcludes
rem Collect tracked overlay paths relative to OVERLAY_DIR, before entering v8.
for /f "delims=" %%H in ('call git -C "%OVERLAY_DIR%" mktree ^<NUL') do set "EMPTY_TREE=%%H"
if not defined EMPTY_TREE (
    echo Error: could not get the empty-tree hash from "%OVERLAY_DIR%".
    exit /b 1W
)

echo patches > "%EXCLUDE_FILES%"
call git -C "%OVERLAY_DIR%" diff --cached --name-only --relative "%EMPTY_TREE%" -- . >>%EXCLUDE_FILES%
if errorlevel 1 (
    echo Error: could not collect overlay paths.
    del "%EXCLUDE_FILES%" 2>nul
    exit /b 1
)

:applyExcludes
pushd "%V8%" 2>nul
if errorlevel 1 (
    echo Error: cannot enter V8 directory "%V8%".
    exit /b 1
)

call git rev-parse --show-toplevel >nul 2>&1
if errorlevel 1 (
    echo Error: "%CD%" is not a Git repository.
    popd
    exit /b 1
)

for /f "delims=" %%G in ('call git rev-parse --git-path info/exclude') do set "EXCLUDE=%%G"
for %%I in ("%EXCLUDE%") do set "EXCLUDE=%%~fI"

if not exist "%EXCLUDE%" (
    type nul > "%EXCLUDE%"
    if errorlevel 1 (
        echo Error: could not create "%EXCLUDE%".
        popd
        exit /b 1
    )
)

for /f "usebackq delims=" %%F in ("%EXCLUDE_FILES%") do call :addExclude "%%F"
popd

del "%EXCLUDE_FILES%" 2>nul
exit /b 0

:addExclude
for /f "tokens=* delims= " %%A in ("%~1") do set "ENTRY=/%%A"
findstr /n /R /c:"^%ENTRY%!LF!" "%EXCLUDE%" >nul 2>&1
if not errorlevel 1 exit /b 0
>>"%EXCLUDE%" <nul set /p "=!ENTRY!!LF!"
exit /b
