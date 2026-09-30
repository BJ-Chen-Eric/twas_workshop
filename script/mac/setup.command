#!/bin/bash
# Double-click version of setup.sh (same folder). Keeps the window open
# so you can see the result. See docs/native_setup_guide.md if
# double-clicking doesn't work (right-click → Open → confirm).
cd "$(dirname "$0")"
bash setup.sh
echo ""
read -p "Setup finished (or failed above) — press Enter to close this window..."
