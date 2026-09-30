#!/bin/bash
# THE ONE THING TO RUN on Mac — checks for Python; if missing, offers to
# install Homebrew (if needed) then Python via Homebrew, each gated by a
# y/n (both need your password). Then hands off to script/setup.py.
# UNTESTED as of 2026-09-21 (no live runs on Eric's machine) — verify
# before relying on it. See docs/native_setup_guide.md.

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

manual_instructions() {
    echo "=================================================================="
    echo "Python wasn't found on this computer."
    echo "1. Go to https://www.python.org/downloads/release/python-3119/"
    echo "   and download the macOS installer (Python 3.11 — recommended:"
    echo "   pandas has a ready-made package for it, so setup doesn't need"
    echo "   to compile anything. Newer Pythons work too, just slower to"
    echo "   set up the first time — see docs/native_setup_guide.md)."
    echo "2. Run the installer, following the prompts."
    echo "3. Close this terminal, open a new one, and run this script again:"
    echo "     bash script/mac/setup.sh"
    echo "=================================================================="
}

confirm() {
    read -r -p "$1 [y/N] " reply
    case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

PYTHON=""
for candidate in python3 python; do
    if command -v "$candidate" >/dev/null 2>&1; then
        PYTHON="$candidate"
        break
    fi
done

if [ -z "$PYTHON" ]; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew (needed to install Python automatically) isn't on"
        echo "this computer."
        if confirm "Install Homebrew now? (needs your Mac password)"; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    fi
    if command -v brew >/dev/null 2>&1; then
        # python@3.11 specifically, not generic "python3" (which installs
        # whatever's newest) — pandas 1.5.3 has a ready-made package for
        # 3.11 but not 3.12+, so this sidesteps the whole
        # build-from-source issue documented in discussion.md 2026-09-30.
        if confirm "Install Python 3.11 via 'brew install python@3.11' now?"; then
            brew install python@3.11
        fi
    fi
    for candidate in python3.11 python3 python; do
        if command -v "$candidate" >/dev/null 2>&1; then
            PYTHON="$candidate"
            break
        fi
    done
    if [ -z "$PYTHON" ]; then
        manual_instructions
        exit 1
    fi
fi

echo "Found Python: $($PYTHON --version)"
exec "$PYTHON" script/setup.py
