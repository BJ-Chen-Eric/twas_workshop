
#!/bin/bash
# --- Strict Error Control ---
set -e
set -o pipefail

# # --- 1. Define Paths ---
# # We use PrediXcanAssociation.py instead of PrediXcan.py
# export ASSOC_PY="/home/eric/Analysis/tools/predixcan/MetaXcan-master/software/PrediXcanAssociation.py"

# # CORRECTED PHENO PATH (Added _v2)
# # export PHENO="/home/eric/Analysis/denv_twas/denv_impute_v2/pheno.txt" 
# export OUT_BASE_DIR="/home/eric/Analysis/workshop/predixcan_ss_demo"

# echo "🌟 Starting Standalone Association Loop..."

# # --- 2. Core Association Function ---
# run_association() {
#     predict_file="$1"
    
#     # Extract the base name (e.g., DENV_Adipose_Subcutaneous)
#     basename=$(basename "$predict_file" _predict.txt)
#     OUT_FILE="${OUT_BASE_DIR}/${basename}_association.txt"
#     rm -f "$OUT_FILE" # 確保不存在舊的輸出檔案
    
#     if [ -f "$OUT_FILE" ]; then
#         echo "⏭️  [Skipping] $basename 已經存在，跳過..."
#         return
#     fi

#     echo "📊 [Running] 正在執行關聯分析: $basename"
    
#     python3 "$ASSOC_PY" \
#         --expression_file "$predict_file" \
#         --input_phenos_file "$PHENO" \
#         --input_phenos_column pheno \
#         --output "$OUT_FILE" \
#         --verbosity 0
        
#     echo "✅ [Done] $basename 關聯分析完成！"
# }

# export -f run_association

# # --- 3. Parallel Execution ---
# # Find all successfully generated predict.txt files and run the association
# find "$OUT_BASE_DIR" -name "*_predict.txt" | xargs -n 1 -P 4 -I {} bash -c 'run_association "$@"' _ {}

# echo "🎉 全部組織關聯分析掃描完成！"


MODEL_DIR="/media/eric/Expansion/twas_reference/twas_related/twas_weight/predi_elastic_net_models/db"
TISSUE_FILE="/home/eric/Analysis/workshop/tissue.txt"
GWAS_FILE="/home/eric/Analysis/workshop/gwas_ss/chr10_imputed_gwas.pheno.glm.logistic.hybrid"
OUTPUT_DIR="/home/eric/Analysis/workshop/demo_out"

# /home/eric/Analysis/tools/predixcan/MetaXcan-master/software/PrediXcanAssociation.py
SPREDIXCAN="/home/eric/Analysis/tools/predixcan/MetaXcan-master/software/SPrediXcan.py"
while read -r tissue || [ -n "$tissue" ]; do
    echo "Running SPrediXcan v8 (elastic net) for $tissue"

    python $SPREDIXCAN \
        --model_db_path "${MODEL_DIR}/en_${tissue}.db" \
        --covariance "${MODEL_DIR}/en_${tissue}.txt.gz" \
        --gwas_file "$GWAS_FILE" \
        --snp_column ID \
        --effect_allele_column REF \
        --non_effect_allele_column ALT \
        --zscore_column Z_STAT \
        --gwas_N 4087 \
        --output_file "${OUTPUT_DIR}/${tissue}_DENV_SS_SPrediXcan_v7.csv"

done < "$TISSUE_FILE"
