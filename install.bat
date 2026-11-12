@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PATCH=%SCRIPT_DIR%overlay.patch"
set "V8="
set "FORCE=0"

rem Accept --v8=PATH or one positional path.
for %%A in (%*) do (
    set "ARG=%%~A"
    call :parseArg
)

rem With no path argument, use the current directory.
if not defined V8 set "V8=%CD%"

if not exist "%PATCH%" (
    echo Error: overlay.patch not found beside install.bat.
    exit /b 1
)

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

echo Files in the patch:
call git apply --stat "%PATCH%"
if errorlevel 1 (
    echo Error: could not read the patch.
    popd
    exit /b 1
)

echo.
echo Checking for conflicts...
call git apply --check "%PATCH%"
if not errorlevel 1 goto apply_patch

if %FORCE%==1 goto do_cleanup
call :promptForce
if errorlevel 1 goto patch_conflict

:do_cleanup
call :cleanup
if errorlevel 1 goto patch_conflict

:apply_patch
call git apply "%PATCH%"
if errorlevel 1 (
    echo Error: patch application failed.
    popd
    exit /b 1
)
goto patch_applied

:patch_conflict
echo Error: patch conflicts with files already present. Nothing was applied.
popd
exit /b 1

:patch_applied
echo Patch applied successfully.
popd

call "%SCRIPT_DIR%add-excludes.bat" "%V8%"
if errorlevel 1 (
    echo Error: failed to update .git/info/exclude.
    popd
    exit /b 1
)
exit /b 0

:cleanup
set "FILES=%SCRIPT_DIR%overlay-files.txt"
if not exist "%FILES%" (
    echo Error: overlay-files.txt not found.
    exit /b 1
)

for /f "usebackq delims=" %%F in ("%FILES%") do call :cleanupFile "%%F"
if errorlevel 1 exit /b 1
exit /b 0

:cleanupFile
set "REL=%~1"
set "REL=%REL:/=\%"
for %%I in ("%V8%\%REL%") do set "TARGET=%%~fI"

if exist "%TARGET%" (
    echo Deleting "%TARGET%"
    del /f /q "%TARGET%"
    if errorlevel 1 (
        echo Error: could not delete "%TARGET%".
        exit /b 1
    )
)
exit /b 0

:promptForce
set "ANSWER="
set /p "ANSWER=Delete the overlay destination files listed in overlay-files.txt and retry? [y/N] "
if /i "%ANSWER%"=="Y" exit /b 0
if /i "%ANSWER%"=="YES" exit /b 0
exit /b 1

:parseArg
if /i "%ARG:~0,5%"=="--v8=" set "V8=%ARG:~5%"
if not "%ARG:~0,2%"=="--" set "V8=%ARG%"
if /i "%ARG%"=="-f" set "FORCE=1"
if /i "%ARG%"=="--force" set "FORCE=1"
exit /b
