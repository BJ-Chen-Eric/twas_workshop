@echo off
REM Double-click version of running the tissue TWAS analysis
REM (script\step2_run_native_tissue.py). Checks the venv exists (i.e.
REM setup has actually been run) before trying to use it, and calls
REM that venv's python explicitly rather than relying on whatever
REM "python" happens to resolve to on PATH. See
REM docs/native_setup_guide.md. Double-clickable, or run from
REM PowerShell/Command Prompt: script\windows\step2_run_native_tissue.bat

cd /d "%~dp0..\.."

if not exist "venv\Scripts\python.exe" (
    echo ==================================================================
    echo venv not found -- run setup first: double-click
    echo script\windows\step1_setup.bat, then re-run this.
    echo ==================================================================
    pause
    exit /b 1
)

venv\Scripts\python.exe script\step2_run_native_tissue.py

echo.
pause
