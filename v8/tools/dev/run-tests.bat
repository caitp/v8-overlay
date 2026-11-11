@echo off
setlocal

set "ARCH="
set "OUTDIR="
set "NEXT="
for %%A in (%*) do (
  set "ARG=%%~A"

  if defined NEXT (
    if "!NEXT!"=="arch" set "ARCH=--arch=%%~A"
    if "!NEXT!"=="outdir" set "OUTDIR=%%~A"
    set "NEXT="
  ) else (
    if /i "!ARG!"=="--arch" set "NEXT=arch"
    if /i "!ARG!"=="--outdir" set "NEXT=outdir"
    if /i "!ARG:~0,7!"=="--arch=" set "ARCH=!ARG:~7!"
    if /i "!ARG:~0,9!"=="--outdir=" set "OUTDIR=!ARG:~9!"
  )
)

if not defined ARCH if defined OUTDIR (
  set "DIR=!OUTDIR:\= !"
  set "DIR=!DIR:/= !"
  set "DIR=!DIR:.= !"
  set "DIR=!DIR:-= !"

  for %%A in (!DIR!) do (
    if not defined ARCH if /i "%%A"=="arm64" set "ARCH=--arch=arm64"
    if not defined ARCH if /i "%%A"=="riscv64" set "ARCH=--arch=riscv64"
    if not defined ARCH if /i "%%A"=="loong64" set "ARCH=--arch=loong64"
    if not defined ARCH if /i "%%A"=="mips64el" set "ARCH=--arch=mips64el"
    if not defined ARCH if /i "%%A"=="ppc64" set "ARCH=--arch=ppc64"
    if not defined ARCH if /i "%%A"=="s390x" set "ARCH=--arch=s390x"
    if not defined ARCH if /i "%%A"=="ia32" set "ARCH=--arch=ia32"
    if not defined ARCH if /i "%%A"=="arm" set "ARCH=--arch=arm"
    if not defined ARCH if /i "%%A"=="x64" set "ARCH=--arch=x64"
  )
)
if not defined ARCH set "ARCH=--arch=x64"

pushd "%~dp0..\.." || exit /b 1
python3 "%~dp0..\run-tests.py" %ARCH% %*
set "result=%ERRORLEVEL%"
popd
exit /b %result%
