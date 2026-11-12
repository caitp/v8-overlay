@echo off
setlocal

set "V8_OVERLAY=%~dp0v8"
set "SCRIPT_DIR=%~dp0"

for /f "delims=" %%H in ('git mktree ^<NUL') do set "EMPTY_TREE=%%H"

if not defined EMPTY_TREE (
  echo Failed to get the empty-tree hash.
  exit /b 1
)

git -C "%V8_OVERLAY%" diff --cached --relative "%EMPTY_TREE%" -- . > %SCRIPT_DIR%overlay.patch
git -C "%V8_OVERLAY%" diff --cached --name-only --relative "%EMPTY_TREE%" -- . > %SCRIPT_DIR%overlay-files.txt
if errorlevel 1 exit /b 1
