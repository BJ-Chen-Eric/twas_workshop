@echo off
REM THE ONE THING TO RUN on Windows -- checks for Python; if missing,
REM offers to install it via winget (y/n first). If Python 3.12+ is
REM already present, prefers a side-installed 3.11 for this project's
REM venv if available (avoids a real, confirmed failure needing
REM Microsoft C++ Build Tools -- see discussion.md 2026-09-30). Then
REM runs script\setup.py. The Python-detection/3.11-preference logic is
REM written but NOT hands-on verified on Windows (no Windows machine
REM available) -- the underlying pandas build failure it works around
REM IS confirmed real, 2026-09-30. See docs/native_setup_guide.md.
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

py -3.11 --version >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Using Python 3.11 for this project's venv instead of %PYVER%
    echo -- pandas has a ready-made package for 3.11, so nothing needs
    echo compiling. Your existing Python installation is untouched.
    py -3.11 script\setup.py
    goto :end
)

echo.
echo NOTE: %PYVER% detected. pandas may need Microsoft C++ Build Tools
echo to install on Windows for Python 3.12+, which most computers don't
echo have. If setup below fails mentioning "Microsoft Visual C++ 14.0",
echo install Python 3.11 (winget install -e --id Python.Python.3.11)
echo and re-run this script -- see docs/native_setup_guide.md.

:run_setup
python script\setup.py

:end
echo.
pause
