#!/bin/bash
# Double-click version of ../step3_run_native_singlecell.sh (optional
# cell-type track, synthetic genotype data). Keeps the window open so
# you can see the result (or any error). See docs/1_native_setup_guide.md
# if double-clicking doesn't work (right-click → Open → confirm).
cd "$(dirname "$0")"
bash ../step3_run_native_singlecell.sh
echo ""
read -p "Finished (or failed above) — press Enter to close this window..."
