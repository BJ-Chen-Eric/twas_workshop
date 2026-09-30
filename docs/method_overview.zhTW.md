# 這個 Workshop 實際上在做什麼

## 要回答的問題

一個基因*基因型預測出來的*表現量,是不是跟某個 trait 有關聯?這正是
transcriptome-wide association study(TWAS)要檢定的問題——而
**S-PrediXcan** 就是我們用來回答這個問題的工具。

## 為什麼是「預測的」表現量,不是實際量測的表現量

要量測真實的基因表現量,需要組織樣本——大部分研究(包括這個 workshop
用的 GWAS)都沒有這種樣本。S-PrediXcan 改用一個**權重模型**,這個模型
是另外訓練出來的(用像 GTEx 這樣的參考資料),用來根據一個人在附近
幾個 SNP 上的基因型,預測某個基因的表現量大概是多少。把這個權重模型
跟 **GWAS summary statistics**(已經算好的 SNP-trait 關聯結果——完全
不需要個人層級的基因型)結合起來,S-PrediXcan 就能用數學方式估計
基因-trait 的關聯,完全不用真的去量測表現量。

這也是為什麼這個 workshop 可以完全建立在公開/衍生的 summary 資料
上——不需要受限的個人層級基因型。

## 你實際在跑的東西

`script/run_native.py`(或 `run_native.sh`)會針對兩個組織(Spleen、
Whole_Blood)各跑一次迴圈,每次都用下面這些東西呼叫 S-PrediXcan:
- 那個組織的**權重模型**(`tissue_twas_weight/en_<tissue>.db`)以及對應
  的 **SNP covariance 矩陣**(`en_<tissue>.txt.gz`——記錄附近 SNP
  彼此的相關程度,統計上要有效需要這個)
- 一條染色體的 **GWAS summary statistics**
  (`gwas_ss/chr10_imputed_gwas...hybrid`)——真實的 SNP 層級關聯結果,
  不需要個人層級基因型
- 這份 GWAS 跑的時候用的樣本數(`--gwas_N`)

對於權重模型有涵蓋、而且跟 GWAS 有 SNP 重疊的每個基因,都會輸出一列
結果。

## 怎麼看輸出結果

每個組織的輸出 CSV(在 `out/` 裡)每個基因一列:

| 欄位 | 代表意義 |
|---|---|
| `gene`、`gene_name` | Ensembl ID 跟基因符號 |
| `zscore`、`pvalue` | 實際的關聯檢定結果——**請用這兩個**,不要用 `effect_size` |
| `effect_size` | 這次執行每一列都會是 `NA`——這是預期的,不是 bug(見下面) |
| `n_snps_used` / `n_snps_in_model` | 模型裡實際能用的 SNP 有幾個——數字太少代表那個基因的預測比較不可靠 |

**為什麼 `effect_size` 永遠是 `NA`**:它需要 GWAS 的 beta + 標準誤;
這次執行改用直接提供 Z-score(一種常見的 GWAS summary-stat 格式),
S-PrediXcan 可以從這個算出顯著性檢定,但算不出有尺度的效應值。不用
想辦法去「修好」它——解讀跟排序請改用 `zscore`/`pvalue`。

**沒有基因組座標欄位**:S-PrediXcan 的輸出是依基因組織的,不是依
SNP,所以不像原始 GWAS 結果那樣每個 SNP 都有唯一座標。如果你想依
基因組位置畫圖(例如 Manhattan 風格的圖),需要另外查每個基因的座標
(例如透過 Ensembl/gencode)。

## 最重要的但書

這裡出現顯著結果,代表那個基因*預測出來*的表現量跟 trait 有關聯——
**不代表**那個基因真的造成這個 trait。基因組上彼此靠近的兩個基因,常常
共享同一批底層的 SNP(linkage disequilibrium),所以 TWAS 有訊號,有
可能指到「錯的」基因,只是剛好跟真正的因果基因離得很近。有專門的後續
方法可以處理這個問題(檢查 GWAS 跟 eQTL 的訊號是不是真的共享同一個
因果變異位點)——不在這場 workshop 的範圍內,但值得知道:這只是個
起點,不是最終答案。
