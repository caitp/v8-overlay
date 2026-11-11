@echo off
setlocal

set "python_script=%~dpn0.py"
python3 "%python_script%" %*
exit /b %errorlevel%
