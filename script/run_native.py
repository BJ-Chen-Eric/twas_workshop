#!/usr/bin/env python3
"""
Runs S-PrediXcan for every tissue in tissue.txt, against the venv created
by script/setup.py. Cross-platform equivalent of script/run_native.sh
(that one's Mac/Linux-only, bash-based) — use this one on Windows, or
anywhere you'd rather not rely on bash.

Usage (from a terminal, after script/setup.py has finished successfully):
    venv/bin/python script/run_native.py         (Mac/Linux)
    venv\\Scripts\\python.exe script\\run_native.py  (Windows)
"""
import os
import subprocess
import sys

WORKSHOP_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MODEL_DIR = os.path.join(WORKSHOP_DIR, "tissue_twas_weight")
TISSUE_FILE = os.path.join(WORKSHOP_DIR, "tissue.txt")
GWAS_FILE = os.path.join(
    WORKSHOP_DIR, "gwas_ss", "chr10_imputed_gwas.pheno.glm.logistic.hybrid"
)
OUTPUT_DIR = os.path.join(WORKSHOP_DIR, "out")
SPREDIXCAN = os.path.join(
    WORKSHOP_DIR, "tools", "MetaXcan-master", "software", "SPrediXcan.py"
)
GWAS_N = "4087"  # see docs/data_requirements.md re: 4087 vs. 4028 discrepancy

if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    with open(TISSUE_FILE) as f:
        tissues = [line.strip() for line in f if line.strip()]

    for tissue in tissues:
        print(f"\n==> Running SPrediXcan for {tissue}")
        subprocess.run([
            sys.executable, SPREDIXCAN,
            "--model_db_path", os.path.join(MODEL_DIR, f"en_{tissue}.db"),
            "--covariance", os.path.join(MODEL_DIR, f"en_{tissue}.txt.gz"),
            "--gwas_file", GWAS_FILE,
            "--snp_column", "ID",
            "--effect_allele_column", "REF",
            "--non_effect_allele_column", "ALT",
            "--zscore_column", "Z_STAT",
            "--gwas_N", GWAS_N,
            "--output_file", os.path.join(OUTPUT_DIR, f"{tissue}_SPrediXcan.csv"),
        ], check=True)

    print(f"\n==> Done — output written to {OUTPUT_DIR}/")
    print("    Compare against sever_folder/demo_out/ (Eric's copy) to verify.")
