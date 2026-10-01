#!/usr/bin/env python3
"""
Runs individual-level PrediXcan.py (NOT SPrediXcan.py) for every cell
type in celltype.txt that has SYNTHETIC genotype data available in
celltype_genotype_synthetic/ — never real individuals; see
sever_folder/script/generate_synthetic_celltype_genotypes.py (and
discussion.md 2026-09-30/2026-10-01) for how that data was made and why
synthetic. Skips gracefully for any cell type without generated data
yet. Cross-platform equivalent of script/run_native_singlecell.sh (that
one's Mac/Linux-only, bash-based) — use this one on Windows, or anywhere
you'd rather not rely on bash.

IMPORTANT: the synthetic genotypes have no real linkage/haplotype
structure between SNPs (deliberate, for safety), so predicted
expression from this run will be close to statistical noise. This
demonstrates the pipeline running end-to-end on an individual-level
genotype input — it is NOT a real biological finding. See
docs/method_overview.md.

Usage (from a terminal, after script/setup.py has finished successfully):
    venv/bin/python script/run_native_singlecell.py         (Mac/Linux)
    venv\\Scripts\\python.exe script\\run_native_singlecell.py  (Windows)
"""
import os
import subprocess
import sys

WORKSHOP_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MODEL_DIR = os.path.join(WORKSHOP_DIR, "celltype_twas_weight")
CELLTYPE_FILE = os.path.join(WORKSHOP_DIR, "celltype.txt")
GENOTYPE_DIR = os.path.join(WORKSHOP_DIR, "celltype_genotype_synthetic")
OUTPUT_DIR = os.path.join(WORKSHOP_DIR, "out")
PREDIXCAN = os.path.join(
    WORKSHOP_DIR, "tools", "MetaXcan-master", "software", "PrediXcan.py"
)

if __name__ == "__main__":
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    with open(CELLTYPE_FILE) as f:
        celltypes = [line.strip() for line in f if line.strip()]

    ran_any = False
    for celltype in celltypes:
        dosage = os.path.join(GENOTYPE_DIR, f"{celltype}_synthetic_chr7.dosage.txt")
        sample_ids = os.path.join(GENOTYPE_DIR, f"{celltype}_synthetic_chr7.sample_ids.txt")
        pheno = os.path.join(GENOTYPE_DIR, f"{celltype}_synthetic_chr7.pheno.txt")
        if not os.path.exists(dosage) or not os.path.exists(sample_ids) or not os.path.exists(pheno):
            print(f"\n==> Skipping {celltype} — no synthetic genotype data "
                  f"for it yet (expected {dosage})")
            continue

        print(f"\n==> Running PrediXcan for {celltype} (synthetic genotype data)")
        ran_any = True
        subprocess.run([
            sys.executable, PREDIXCAN,
            "--model_db_path", os.path.join(MODEL_DIR, f"{celltype}.db"),
            "--text_genotypes", dosage,
            "--text_sample_ids", sample_ids,
            "--input_phenos_file", pheno,
            "--input_phenos_column", "pheno",
            "--prediction_output", os.path.join(OUTPUT_DIR, f"{celltype}_predict.txt"),
            "--prediction_summary_output", os.path.join(OUTPUT_DIR, f"{celltype}_summary.txt"),
            "--output", os.path.join(OUTPUT_DIR, f"{celltype}_association.txt"),
        ], check=True)

    if not ran_any:
        print("\n==> No cell types had synthetic genotype data available — nothing run.")
        sys.exit(1)

    print(f"\n==> Done — NOTE: this used SYNTHETIC genotype data with no real")
    print("    linkage structure, so results are close to statistical noise")
    print("    by design (demonstrates the pipeline running end-to-end, not a")
    print("    real biological finding). See docs/method_overview.md.")
