@echo off
REM THE ONE THING TO RUN on Windows -- checks for Python; offers to
REM install it via winget (y/n first) if missing entirely. If Python
REM 3.12+ is already present, uses a side-installed 3.11 for this
REM project's venv if available, and OFFERS to install 3.11 via winget
REM (y/n) if it's not -- avoids a real, confirmed failure needing
REM Microsoft C++ Build Tools (see discussion.md 2026-09-30). Earlier
REM version of this script only checked for an existing 3.11 without
REM ever offering to install it when 3.12+ was already on PATH -- fixed
REM 2026-09-30 after a real run showed the gap. Then runs
REM script\setup.py. This logic is NOT hands-on verified on Windows (no
REM Windows machine available) -- the underlying pandas build failure it
REM works around IS confirmed real. See docs/native_setup_guide.md.
REM Double-clickable, or run from PowerShell/Command Prompt:
REM script\windows\setup.bat

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
for /f "delims=" %%v in ('python --version') do set PYVER=%%v
echo Found Python: %PYVER%

REM If this Python is 3.12+, prefer a side-installed 3.11 for THIS venv
REM if one's available via the "py" launcher -- pandas has a ready-made
REM package for 3.11 but needs a C/C++ compiler to build on 3.12+, which
REM most Windows computers don't have (confirmed on a real run,
REM 2026-09-30: "Microsoft Visual C++ 14.0 or greater is required").
REM Doesn't touch/uninstall the 3.12 already there -- just uses 3.11 for
REM this project's venv instead.
python -c "import sys; sys.exit(0 if sys.version_info>=(3,12) else 1)" >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :run_setup

call :use_311_if_present
if %ERRORLEVEL% EQU 0 goto :end

REM 3.11 isn't already there. This is where the ORIGINAL version of this
REM script fell short (found 2026-09-30, real Windows run): it only ever
REM OFFERED to install Python via winget when NO Python was found at
REM all -- if 3.12+ was already on PATH, it skipped straight past that
REM offer and just printed a passive suggestion, never actually
REM installing 3.11. Fixed: offer it here too, the same way.
where winget >nul 2>nul
if %ERRORLEVEL% NEQ 0 goto :warn_and_proceed

echo.
echo %PYVER% is already installed, but pandas needs Microsoft C++ Build
echo Tools to build on Windows Python 3.12+, which most computers don't
echo have. Installing Python 3.11 alongside it (not replacing it) avoids
echo this entirely -- pandas has a ready-made package for 3.11.
echo ==================================================================
set /p REPLY="Install Python 3.11 via winget now? [y/N] "
if /i "%REPLY%"=="y" goto :install_311_now
if /i "%REPLY%"=="yes" goto :install_311_now
goto :warn_and_proceed

:install_311_now
winget install -e --id Python.Python.3.11
call :use_311_if_present
if %ERRORLEVEL% EQU 0 goto :end
echo.
echo Install finished but the py launcher still can't find 3.11. Close
echo this window, open a new one, and run this script again -- if it
echo still doesn't pick it up, install manually from
echo https://www.python.org/downloads/release/python-3119/ instead.
pause
exit /b 1

:warn_and_proceed
echo.
echo NOTE: proceeding with %PYVER% as-is. If setup below fails
echo mentioning "Microsoft Visual C++ 14.0", install Python 3.11
echo (winget install -e --id Python.Python.3.11) and re-run this script
echo -- see docs/native_setup_guide.md.

:run_setup
python script\setup.py

:end
echo.
pause
exit /b 0

:use_311_if_present
REM Helper: if "py -3.11" resolves, run setup with it and return success
REM (errorlevel 0); otherwise return failure (errorlevel 1) and do
REM nothing else. Called with "call" so the caller can react to the
REM result instead of the whole script ending here.
py -3.11 --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 exit /b 1
echo.
echo Using Python 3.11 for this project's venv instead of %PYVER% --
echo pandas has a ready-made package for 3.11, so nothing needs
echo compiling. Your existing Python installation is untouched.
py -3.11 script\setup.py
exit /b 0
