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

## 什麼是 eQTL?

**eQTL**(expression quantitative trait locus,表現量化性狀位點)是
一個跟附近某個基因表現量有統計關聯的基因變異(SNP)——這個 SNP 上
某些基因型會對應到那個基因製造出比較多的 mRNA,另一些則比較少。
eQTL 的找法跟 GWAS 找 trait 關聯一樣,只是把「表現量」當成那個
「trait」,而不是疾病/表現型——用的是像 GTEx 這樣的參考世代,裡面
同一群人的基因型跟真實的組織表現量都有直接量測到。

前面提到的**權重模型**,就是用這種真實的 eQTL 證據建出來的:對每個
基因,列出附近一小串 SNP,以及每個 SNP 的基因型會讓預測表現量往哪個
方向、移動多少——這是用參考世代真實的 eQTL 學一次就學好,之後可以
套用在任何從沒量測過表現量的新基因型或 summary statistics 上。這種
「學一次、重複套用」正是 TWAS 之所以可行的關鍵技巧。

具體來說,對一個基因,預測表現量就是對它附近所有 SNP 做加權總和:

```
predicted expression = beta_1 × SNP_1 + beta_2 × SNP_2 + ... + beta_n × SNP_n
```

- `SNP_i` 是這個人在第 i 個 SNP 上的基因型(0、1 或 2 個替代等位基因
  的拷貝數——如果是 imputed 資料,則是 0–2 之間的 dosage 值)。
- `beta_i` 是這個 SNP 的**eQTL 效應值**——多一個替代等位基因拷貝會讓
  表現量往哪個方向移動多少,從參考世代估計出來。這正是模型 `.db`
  檔案裡,針對那個 SNP/基因配對存成 `weight` 的數字。

S-PrediXcan 實際上不會直接在個人基因型上算這個總和(它是從 GWAS
summary statistics 出發,用數學方法把同樣的 beta 摺進基因層級的
檢定裡)——但個人層級的 `PrediXcan.py`(選用的 cell-type 線)確實
就是逐個人算這個公式,算出來的結果就是那條線 `predict.txt` 輸出的
內容。

## 你實際在跑的東西

`script/step2_run_native_tissue.py`(或 `step2_run_native_tissue.sh`)會針對兩個組織(Spleen、
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
| `gene` | Ensembl 基因 ID(可能帶版本號後綴,例如 `.13`) |
| `gene_name` | 基因符號(例如 `C10orf128`) |
| `zscore` | 關聯檢定的統計量——**請用這個**,不要用 `effect_size` |
| `effect_size` | 這次執行每一列都會是 `NA`——這是預期的,不是 bug(見下面) |
| `pvalue` | 對應 `zscore` 的雙尾 p 值——跟 `zscore` 一起用 |
| `var_g` | 權重模型估計出來的、這個基因*預測*表現量的變異量(用模型的權重跟參考 SNP covariance 算出來)。是統計量背後用的內部標準化項——本身不需要去解讀。 |
| `pred_perf_r2` | 這個基因的*預測*表現量跟*實際量測*表現量之間的相關係數平方(**R²**),是在模型原始訓練時做交叉驗證算出來的(例如把部分 GTEx 樣本保留下來,用基因型預測他們的表現量,再跟他們真正量測到的表現量算相關)。是模型檔案裡固定的屬性,跟這次執行的 GWAS/trait 完全無關。 |
| `pred_perf_pval` | 檢定「預測表現量跟實際表現量的相關性是否顯著不等於零」的 p 值——跟上面一樣是訓練時就算好的,不是這次執行的結果。 |
| `pred_perf_qval` | `pred_perf_pval` 在這個模型涵蓋的所有基因之間做 FDR 校正後的版本(校正同時對上千個基因做檢定帶來的誤判)。**不是每個模型檔案都有存這個數字**——直接查過 `en_Whole_Blood.db`:裡面全部 7,252 個基因的 `pred.perf.qval` 都是 `NULL`,不只是這一個基因而已。 |
| `n_snps_used` | 這個基因的檢定實際用了幾個 SNP——(模型的 SNP)∩(covariance 檔案)∩(這次 GWAS 檔案)三者的交集。 |
| `n_snps_in_cov` | 這個基因在模型裡的 SNP,有幾個也出現在 covariance 檔案裡。 |
| `n_snps_in_model` | 權重模型針對這個基因定義的 SNP 總數,還沒做任何重疊檢查之前的數字。 |

所以對一個基因來說,`n_snps_used ≤ n_snps_in_cov ≤ n_snps_in_model`
——每一步都在往下篩選出真正能用的部分。如果 `n_snps_used` 相對
`n_snps_in_model` 偏低,代表模型原本設計要用的 SNP 面板裡,只有少數
真的有 GWAS 資料可以用,所以這個基因的預測比模型原本設計的更依賴
少數幾個 SNP。

`pred_perf_*` 這幾欄,建議在腦中跟其他欄位分開看:它們描述的是這個
*模型*本身預測表現量的好壞(訓練時就固定下來的),而
`zscore`/`pvalue`/`var_g`/`n_snps_*` 描述的則是這個模型實際套用到
*這次*的 GWAS 上發生了什麼。

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
起點,不是最終答案。想知道這些方法(MR、COLOC、SuSiE)的白話介紹,
見 [`causal_followup_methods.zhTW.md`](./causal_followup_methods.zhTW.md)。

## 一開始那份 GWAS 檔案是哪來的?

這個 workshop 是從一份已經算好的 summary statistics 檔案開始的。如果
想了解原始的基因型樣本是怎麼變成那份檔案的,見
[`gwas_to_summary_stats.zhTW.md`](./gwas_to_summary_stats.zhTW.md)。

## 那個選用的 cell-type 線是怎麼回事?

`step3_run_native_singlecell.py`/`.sh` 跑的是一個相關但不同的方法——
**個人層級**的 PrediXcan(不是 S-PrediXcan),直接從基因型預測
表現量、再對表現型做迴歸,而不是從 summary statistics 出發。背後的
基因型資料完全是**合成**的:針對每個 SNP,用真實的等位基因頻率
模擬出來,沒有任何真實個人的基因組,SNP 之間也不保留真實的遺傳連鎖。
最後這點很重要——鄰近 SNP 之間真實的連鎖,正是多 SNP 預測模型賴以
運作的東西,沒有它,這裡的預測表現量本來就會接近統計雜訊。這條線是
用來示範個人層級的流程能跑完,不是要示範真的生物學訊號。

### 怎麼看 cell-type 的輸出

這條線會針對每個 cell type,在 `out/` 裡寫出三個檔案(可以對照
`demo_out/CD14-positive_monocyte_*` 這份真實的參考輸出):

| 檔案 | 每一列是 | 關鍵欄位 |
|---|---|---|
| `<celltype>_association.txt` | 一個基因 | `effect`、`se`、`zscore`、`pvalue`——關聯檢定的結果。跟組織線的 `effect_size` 不同,這裡的 `effect`/`se` 是真的數字,不是 `NA`——個人層級的 PrediXcan 直接把預測表現量對表現型做迴歸,自然就會算出這兩個值。 |
| `<celltype>_summary.txt` | 一個基因 | `gene_name`、`n_snps_in_model`、`n_snps_used`、`pred_perf_r2`、`pred_perf_pval`——這個權重模型預測該基因表現量的好壞程度,跟這次執行用的表現型無關。這次用合成資料跑,`n_snps_used` 常常是 `NA`。 |
| `<celltype>_predict.txt` | 一個(合成)樣本 | 每個基因各一欄——那個人的預測表現量。這是另外兩個檔案的中間產物,不需要逐列去讀。 |

`association.txt` 裡的 `n_samples` 跟 `status` 是記帳用的欄位
(這次執行裡固定是 `200` 跟 `NA`)——不用追究。
