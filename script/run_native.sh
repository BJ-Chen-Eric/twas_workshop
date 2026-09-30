#!/bin/bash
set -e
# Runs the actual S-PrediXcan workshop analysis against the venv created
# by script/setup.py (see docs/native_setup_guide.md). Portable: locates
# the workshop root relative to this script's own location. Windows or
# bash-averse users: script/run_native.py does the same thing in pure
# Python.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSHOP_DIR"

MODEL_DIR="tissue_twas_weight"
TISSUE_FILE="tissue.txt"
GWAS_FILE="gwas_ss/chr10_imputed_gwas.pheno.glm.logistic.hybrid"
OUTPUT_DIR="out"
SPREDIXCAN="tools/MetaXcan-master/software/SPrediXcan.py"

mkdir -p "$OUTPUT_DIR"

while read -r tissue || [ -n "$tissue" ]; do
    [ -z "$tissue" ] && continue
    echo "==> Running SPrediXcan for $tissue"

    python "$SPREDIXCAN" \
        --model_db_path "${MODEL_DIR}/en_${tissue}.db" \
        --covariance "${MODEL_DIR}/en_${tissue}.txt.gz" \
        --gwas_file "$GWAS_FILE" \
        --snp_column ID \
        --effect_allele_column REF \
        --non_effect_allele_column ALT \
        --zscore_column Z_STAT \
        --gwas_N 4087 \
        --output_file "${OUTPUT_DIR}/${tissue}_SPrediXcan.csv"

done < "$TISSUE_FILE"

echo "==> Done — compare ${OUTPUT_DIR}/ against demo_out/ to verify, e.g.:"
echo "    diff ${OUTPUT_DIR}/Spleen_SPrediXcan.csv demo_out/Spleen_SPrediXcan.csv"
