#!/bin/bash
set -e
# Runs individual-level PrediXcan.py (NOT SPrediXcan.py) for the
# cell-type/single-cell TWAS track, against SYNTHETIC genotype +
# phenotype data (never real individuals) in
# celltype_genotype_synthetic/ — see
# sever_folder/script/generate_synthetic_celltype_genotypes.py (and
# discussion.md 2026-09-30/2026-10-01) for how that data was made and
# why synthetic. Skips gracefully for any cell type in celltype.txt
# that doesn't have synthetic genotype data generated yet.
#
# IMPORTANT: the synthetic genotypes have no real linkage/haplotype
# structure between SNPs (deliberate, for safety), so predicted
# expression from this run will be close to statistical noise. This
# demonstrates the pipeline running end-to-end on an individual-level
# genotype input — it is NOT a real biological finding. See
# docs/method_overview.md.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSHOP_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORKSHOP_DIR"

MODEL_DIR="celltype_twas_weight"
CELLTYPE_FILE="celltype.txt"
GENOTYPE_DIR="celltype_genotype_synthetic"
OUTPUT_DIR="out"
PREDIXCAN="tools/MetaXcan-master/software/PrediXcan.py"

mkdir -p "$OUTPUT_DIR"
ran_any=0

while read -r celltype || [ -n "$celltype" ]; do
    [ -z "$celltype" ] && continue

    DOSAGE="${GENOTYPE_DIR}/${celltype}_synthetic_chr7.dosage.txt"
    SAMPLE_IDS="${GENOTYPE_DIR}/${celltype}_synthetic_chr7.sample_ids.txt"
    PHENO="${GENOTYPE_DIR}/${celltype}_synthetic_chr7.pheno.txt"

    if [ ! -f "$DOSAGE" ] || [ ! -f "$SAMPLE_IDS" ] || [ ! -f "$PHENO" ]; then
        echo "==> Skipping $celltype — no synthetic genotype data for it yet"
        echo "    (expected ${DOSAGE})"
        continue
    fi

    echo "==> Running PrediXcan for $celltype (synthetic genotype data)"
    ran_any=1

    python "$PREDIXCAN" \
        --model_db_path "${MODEL_DIR}/${celltype}.db" \
        --text_genotypes "$DOSAGE" \
        --text_sample_ids "$SAMPLE_IDS" \
        --input_phenos_file "$PHENO" \
        --input_phenos_column pheno \
        --prediction_output "${OUTPUT_DIR}/${celltype}_predict.txt" \
        --prediction_summary_output "${OUTPUT_DIR}/${celltype}_summary.txt" \
        --output "${OUTPUT_DIR}/${celltype}_association.txt"

done < "$CELLTYPE_FILE"

if [ "$ran_any" -eq 0 ]; then
    echo "==> No cell types had synthetic genotype data available — nothing run."
    exit 1
fi

echo "==> Done — NOTE: this used SYNTHETIC genotype data with no real"
echo "    linkage structure, so results are close to statistical noise"
echo "    by design (demonstrates the pipeline running end-to-end, not a"
echo "    real biological finding). See docs/method_overview.md."
