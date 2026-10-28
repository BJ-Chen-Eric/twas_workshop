@echo off
REM Double-click version of running the optional cell-type TWAS track
REM (script\step3_run_native_singlecell.py, synthetic genotype data).
REM Checks the venv exists (i.e. setup has actually been run) before
REM trying to use it, and calls that venv's python explicitly rather
REM than relying on whatever "python" happens to resolve to on PATH.
REM See docs/1_native_setup_guide.md. Double-clickable, or run from
REM PowerShell/Command Prompt: script\windows\step3_run_native_singlecell.bat

cd /d "%~dp0..\.."

if not exist "venv\Scripts\python.exe" (
    echo ==================================================================
    echo venv not found -- run setup first: double-click
    echo script\windows\step1_setup.bat, then re-run this.
    echo ==================================================================
    pause
    exit /b 1
)

venv\Scripts\python.exe script\step3_run_native_singlecell.py

echo.
pause
