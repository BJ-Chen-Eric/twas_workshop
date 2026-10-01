# What This Workshop Actually Does

## The question

Does a gene's *genetically predicted* expression level associate with a
trait? That's what a transcriptome-wide association study (TWAS) tests —
and **S-PrediXcan** is the specific tool we use to answer it.

## Why "predicted" expression, not measured expression

Measuring actual gene expression requires tissue samples, which most
studies (including the GWAS this workshop uses) don't have. Instead,
S-PrediXcan uses a **weight model**, trained separately (using reference
data like GTEx) to predict how much a gene is expressed based on a
person's genotype at a handful of nearby SNPs. Combine that weight model
with **GWAS summary statistics** (already-computed SNP-trait association
results — no individual genotypes needed at all), and S-PrediXcan can
estimate the gene-trait association mathematically, without ever
measuring expression directly.

That's also why this workshop can run entirely on public/derived summary
data — no restricted individual-level genotypes required.

## What you're actually running

`script/run_native.py` (or `run_native.sh`) loops over two tissues
(Spleen, Whole_Blood) and, for each, calls S-PrediXcan with:
- a **weight model** for that tissue (`tissue_twas_weight/en_<tissue>.db`)
  and its paired **SNP covariance matrix**
  (`en_<tissue>.txt.gz` — captures how correlated nearby SNPs are, needed
  for the statistics to be valid)
- the **GWAS summary statistics** for one chromosome
  (`gwas_ss/chr10_imputed_gwas...hybrid`) — real SNP-level association
  results, no individual genotypes
- the sample size the GWAS was run on (`--gwas_N`)

For each gene the weight model covers (that also has SNP overlap with the
GWAS), it outputs one row of results.

## Reading the output

Each tissue's output CSV (in `out/`) has one row per gene:

| Column | What it means |
|---|---|
| `gene`, `gene_name` | Ensembl ID and symbol |
| `zscore`, `pvalue` | The actual association test result — **use these**, not `effect_size` |
| `effect_size` | Will show `NA` for every row in this run — expected, not a bug (see below) |
| `n_snps_used` / `n_snps_in_model` | How many of the model's SNPs were actually usable — low numbers mean less reliable predictions for that gene |

**Why `effect_size` is always `NA`**: it requires a beta + standard error
from the GWAS; this run instead supplies a Z-score directly (a common
GWAS summary-stat format), from which S-PrediXcan can compute a
significance test but not a scaled effect size. Not something to try to
fix — just use `zscore`/`pvalue` for ranking and interpretation.

**No genomic position column**: S-PrediXcan's output is organized by
gene, not by SNP, so there's no single coordinate per row the way a raw
GWAS result has one per SNP. If you want to visualize results by genomic
position (e.g. a Manhattan-style plot), you'd need to look up each gene's
coordinates separately (e.g. via Ensembl/gencode).

## The big caveat

A significant result here means the *predicted* expression of that gene
associates with the trait — it does **not** prove that gene causes the
trait. Two genes near each other in the genome often share the same
underlying SNPs (linkage disequilibrium), so a TWAS hit can point at the
"wrong" gene that just happens to sit near the real causal one. Follow-up
methods exist specifically to address this (checking whether the GWAS and
eQTL signals really do share the same causal variant) — out of scope for
this session, but worth knowing this is a starting point, not a final
answer. See [`causal_followup_methods.md`](./causal_followup_methods.md)
for a plain-language introduction to those methods (MR, COLOC, SuSiE), if
you're curious what comes next.

## Where did the input GWAS file come from?

This workshop starts from an already-computed summary-statistics file.
See [`gwas_to_summary_stats.md`](./gwas_to_summary_stats.md) if you want
to understand how raw genotyped samples turn into that file.
