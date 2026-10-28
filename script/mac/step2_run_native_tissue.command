#!/bin/bash
# Double-click version of ../step2_run_native_tissue.sh. Keeps the
# window open so you can see the result (or any error). See
# docs/native_setup_guide.md if double-clicking doesn't work
# (right-click → Open → confirm).
cd "$(dirname "$0")"
bash ../step2_run_native_tissue.sh
echo ""
read -p "Finished (or failed above) — press Enter to close this window..."
