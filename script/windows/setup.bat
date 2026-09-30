@echo off
REM THE ONE THING TO RUN on Windows -- checks for Python; if missing,
REM offers to install it via winget (y/n first). Then runs
REM script\setup.py. UNTESTED as of 2026-09-21 -- verify before relying
REM on it. See docs/native_setup_guide.md. Double-clickable, or run from
REM PowerShell/Command Prompt: script\windows\setup.bat

cd /d "%~dp0..\.."

where python >nul 2>nul
if %ERRORLEVEL% EQU 0 goto :found

where winget >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :manual

echo ==================================================================
echo Python wasn't found, but this computer has winget, so it can
echo install Python automatically.
echo ==================================================================
set /p REPLY="Run 'winget install -e --id Python.Python.3.11' now? [y/N] "
if /i "%REPLY%"=="y" goto :winget_install
if /i "%REPLY%"=="yes" goto :winget_install
goto :manual

:winget_install
winget install -e --id Python.Python.3.11
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 goto :found
echo.
echo Install finished but Python still isn't on PATH. Close this window,
echo open a new one, and run this script again.
pause
exit /b 1

:manual
echo ==================================================================
echo Python wasn't found ^(or isn't on PATH^) on this computer.
echo.
echo 1. Go to https://www.python.org/downloads/release/python-3119/ and
echo    download the Windows installer for Python 3.11 -- recommended:
echo    pandas has a ready-made package for it, so setup doesn't need to
echo    compile anything. Newer Pythons (3.12+) can also need a C/C++
echo    compiler (Microsoft C++ Build Tools) to finish setup, which most
echo    computers don't have -- see docs/native_setup_guide.md.
echo 2. Run the installer. ON THE FIRST SCREEN, CHECK THE BOX THAT SAYS
echo    "Add python.exe to PATH" -- this is the step almost everyone
echo    misses, and without it this script will keep failing.
echo 3. Close this window, open a new one, and run this script again.
echo ==================================================================
pause
exit /b 1

:found
for /f "delims=" %%v in ('python --version') do echo Found Python: %%v
python script\setup.py

echo.
pause
