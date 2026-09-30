#!/usr/bin/env python3
"""Run this after creating/activating your virtual environment and
`pip install -r requirements.txt` (see docs/native_setup_guide.md).
Checks that everything needed for the workshop is importable and present,
the same idea as the reference template's 00_student_setup script — no
'am I ready?' guesswork.

Usage: python script/00_check_setup.py   (run from the repo root)
"""
import importlib
import os
import sys

# bgen_reader/cyvcf2 deliberately excluded (removed from requirements.txt
# 2026-09-30) — traced every import in SPrediXcan.py's call chain and
# neither is ever used by the toy workshop's summary-stat path; they're
# only for individual-level genotype input (a different pipeline this
# workshop doesn't run). See requirements.txt's comment for the full
# reasoning if this needs revisiting.
REQUIRED_MODULES = [
    "numpy", "pandas", "scipy", "patsy", "h5py", "sqlalchemy",
]

TOOLKIT_PATH = os.path.join("tools", "MetaXcan-master", "software", "SPrediXcan.py")

EXPECTED_DATA = [
    os.path.join("tissue_twas_weight", "en_Spleen.db"),
    os.path.join("tissue_twas_weight", "en_Spleen.txt.gz"),
    os.path.join("tissue_twas_weight", "en_Whole_Blood.db"),
    os.path.join("tissue_twas_weight", "en_Whole_Blood.txt.gz"),
    os.path.join("gwas_ss", "chr10_imputed_gwas.pheno.glm.logistic.hybrid"),
    "tissue.txt",
]


def check_modules():
    print("Packages:")
    missing = []
    for mod in REQUIRED_MODULES:
        try:
            importlib.import_module(mod)
            print(f"  ok       {mod}")
        except Exception as e:
            # Deliberately broad, not just ImportError: a broken
            # transitive dependency (e.g. a version-incompatible dask
            # pulled in by bgen-reader, see discussion.md 2026-09-30) can
            # raise TypeError/AttributeError/etc. mid-import rather than
            # a clean ImportError — this check's whole job is to report
            # status without crashing, so catch broadly and keep going.
            print(f"  MISSING  {mod}  ({type(e).__name__}: {e})")
            missing.append(mod)
    return missing


def check_paths(label, paths):
    print(f"\n{label}:")
    missing = []
    for p in paths:
        ok = os.path.isfile(p)
        print(f"  {'ok      ' if ok else 'MISSING '} {p}")
        if not ok:
            missing.append(p)
    return missing


if __name__ == "__main__":
    print(f"Python: {sys.version}\n")
    missing_mods = check_modules()
    missing_toolkit = check_paths("Toolkit", [TOOLKIT_PATH])
    missing_data = check_paths(
        "Toy data (run script/setup.py first if these are missing)",
        EXPECTED_DATA,
    )

    if missing_mods or missing_toolkit or missing_data:
        print("\nSetup incomplete — see MISSING items above.")
        sys.exit(1)
    print("\nAll good — ready for the workshop!")
