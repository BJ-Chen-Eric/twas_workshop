# What This Workshop Actually Does

## The question

Does a gene's *genetically predicted* expression level associate with a
trait? That's what a transcriptome-wide association study (TWAS) tests —
and **S-PrediXcan** is the specific tool we use to answer it.

## The big picture

The rest of this page explains each piece in detail — here's how they
all fit together first:

```
   [GTEx reference panel]
   (real genotypes + real measured expression, same people)
             │
             ▼  (Elastic Net training — done once, ahead of time,
             │   not something this workshop runs)
   [weight model: en_<tissue>.db + its covariance file]
             │
             │            [your GWAS summary statistics]
             │                       │
             └───────────┬───────────┘
                         ▼
                  [S-PrediXcan]
                         │
                         ▼
       [one row per gene: zscore, pvalue, ...]
```

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

## What's an eQTL?

An **eQTL** (expression quantitative trait locus) is a genetic variant
(a SNP) that's statistically associated with how much a nearby gene is
expressed — some genotypes at that SNP go with more of the gene's
mRNA being made, others with less. eQTLs are found the same way a GWAS
finds trait associations, just with gene expression level as the
"trait" instead of a disease/phenotype — using reference cohorts (like
GTEx) where both genotype and real tissue expression were measured
directly in the same people.

The **weight model** mentioned above is built from exactly this kind
of eQTL evidence: for each gene, it's a short list of nearby SNPs and
how much each one's genotype shifts predicted expression — learned
once from a reference panel's real eQTLs, then reusable on any new
genotypes or summary statistics that never had expression measured at
all. That reuse is the whole trick that makes TWAS possible.

Concretely, for one gene, predicted expression is just a weighted sum
over its nearby SNPs:

```
predicted expression = beta_1 × SNP_1 + beta_2 × SNP_2 + ... + beta_n × SNP_n
```

- `SNP_i` is that person's genotype at SNP *i* (0, 1, or 2 copies of
  the alternate allele — or a dosage between 0–2 for imputed data).
- `beta_i` is that SNP's **eQTL effect size** — how much one more copy
  of the alternate allele shifts expression, estimated from the
  reference panel. This is exactly the number stored as `weight` in
  the model's `.db` file for that SNP/gene pair.

S-PrediXcan never actually computes this sum directly on individual
genotypes (it works from GWAS summary statistics instead, mathematically
folding the same betas into the gene-level test) — but the
individual-level `PrediXcan.py` path (the optional cell-type track)
does compute exactly this formula, one person at a time, which is what
ends up in that track's `predict.txt` output.

## What you're actually running

`script/step2_run_native_tissue.py` (or `step2_run_native_tissue.sh`) loops over two tissues
(Spleen, Whole_Blood) and, for each, calls S-PrediXcan with:
- a **weight model** for that tissue (`tissue_twas_weight/en_<tissue>.db`)
  and its paired **SNP covariance matrix**
  (`en_<tissue>.txt.gz` — captures how correlated nearby SNPs are, needed
  for the statistics to be valid)
- the **GWAS summary statistics** for one chromosome
  (`gwas_ss/chr10_imputed_gwas...hybrid`) — real SNP-level association
  results, no individual genotypes (curious how raw genotyped samples
  turn into a file like this? see
  [`3_gwas_to_summary_stats.md`](./3_gwas_to_summary_stats.md))
- the sample size the GWAS was run on (`--gwas_N`)

For each gene the weight model covers (that also has SNP overlap with the
GWAS), it outputs one row of results.

## Reading the output

Each tissue's output CSV (in `out/`) has one row per gene:

| Column | What it means |
|---|---|
| `gene` | Ensembl gene ID (may carry a version suffix, e.g. `.13`) |
| `gene_name` | Gene symbol (e.g. `C10orf128`) |
| `zscore` | The association test statistic — **use this**, not `effect_size` |
| `effect_size` | Will show `NA` for every row in this run — expected, not a bug (see below) |
| `pvalue` | Two-sided p-value for `zscore` — **use this** alongside `zscore` |
| `var_g` | The weight model's estimated variance of this gene's *predicted* expression (computed from the model's weights and the reference SNP covariance). An internal normalizing term the statistics above are built from — not something to interpret on its own. |
| `pred_perf_r2` | **R²** (squared correlation) between this gene's *predicted* expression and its *actually measured* expression, in cross-validation during the model's original training (e.g. holding out GTEx samples, predicting their expression from genotype, then correlating against their real measured expression). A fixed property of the model file — has nothing to do with this run's GWAS/trait. |
| `pred_perf_pval` | P-value testing whether that predicted-vs-measured correlation is significantly different from zero — same training-time measurement, not this run's result. |
| `pred_perf_qval` | FDR-corrected version of `pred_perf_pval`, across every gene the model covers (correcting for testing thousands of genes at once). **Not every model file populates this** — confirmed directly against `en_Whole_Blood.db`: `pred.perf.qval` is `NULL` for all 7,252 genes in that file, not just this one. |
| `n_snps_used` | How many SNPs were actually used for this gene's test — the overlap of (model SNPs) ∩ (covariance file) ∩ (this run's GWAS file). |
| `n_snps_in_cov` | How many of the model's SNPs for this gene are present in the covariance file. |
| `n_snps_in_model` | Total SNPs the weight model defines for this gene, before any overlap check. |

So for one gene, `n_snps_used ≤ n_snps_in_cov ≤ n_snps_in_model` — each
step narrows to what's actually usable. A low `n_snps_used` relative to
`n_snps_in_model` means less of the model's SNP panel actually had
GWAS data to work with for that gene, so its prediction leans on fewer
SNPs than the model was designed for.

The `pred_perf_*` columns are worth separating mentally from
everything else in the row: they describe how good the *model* is at
predicting expression in general (fixed ahead of time, from training),
while `zscore`/`pvalue`/`var_g`/`n_snps_*` describe what happened when
that model was actually applied to *this* GWAS.

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

## How do I pick out a meaningful gene?

With a few hundred or thousand rows, staring at the raw CSV isn't much
help. These three checks aren't a strict pass/fail rule, but a
reasonable way to tell "worth a closer look" from "probably noise":

1. **Is the model itself any good for this gene?** Check
   `pred_perf_pval < 0.05` and `pred_perf_r2 > 0.01` — i.e. the weight
   model actually predicted real expression reasonably well back when
   it was trained. If it couldn't do that on its own training data,
   its prediction on your GWAS isn't trustworthy either.
2. **Is the GWAS association itself strong enough?** A common
   convention is a transcriptome-wide Bonferroni cutoff:
   `0.05 / (number of genes actually tested)`. The often-quoted
   figure of about `2.5e-6` assumes testing close to the full
   ~20,000-gene transcriptome — **this workshop's toy run tests far
   fewer genes** (count the rows in your own output CSV), so that
   figure is stricter than it needs to be here. Compute your own
   cutoff from your own row count rather than copying `2.5e-6` as-is.
3. **Is the result resting on enough SNPs?** Check `n_snps_used` isn't
   tiny (e.g. 1) — a result built on a single SNP is really just that
   one SNP's GWAS signal wearing a gene's name, not a genuinely
   multi-SNP prediction.

## The big caveat

A significant result here means the *predicted* expression of that gene
associates with the trait — it does **not** prove that gene causes the
trait. Two genes near each other in the genome often share the same
underlying SNPs (linkage disequilibrium), so a TWAS hit can point at the
"wrong" gene that just happens to sit near the real causal one. Follow-up
methods exist specifically to address this (checking whether the GWAS and
eQTL signals really do share the same causal variant) — out of scope for
this session, but worth knowing this is a starting point, not a final
answer. See [`4_causal_followup_methods.md`](./4_causal_followup_methods.md)
for a plain-language introduction to those methods (MR, COLOC, SuSiE), if
you're curious what comes next.

## What about the optional cell-type track?

`step3_run_native_singlecell.py`/`.sh` runs a related but different method —
**individual-level** PrediXcan (not S-PrediXcan), which predicts
expression directly from genotypes and regresses against a phenotype,
rather than working from summary statistics. The genotype data behind
it is entirely **synthetic**: simulated per-SNP from real allele
frequencies, with no real person's genome and no real genetic linkage
preserved between SNPs. That last part matters — real linkage between
nearby SNPs is exactly what a multi-SNP prediction model relies on, so
without it, predicted expression here is close to statistical noise by
design. This track exists to show the individual-level pipeline running
end-to-end, not to demonstrate a real biological signal.

This track covers one cell type, `CD14-positive_monocyte` — when you
run it, you'll see a line like `Skipping plasmablast — no synthetic
genotype data for it yet`. That's expected, not an error: a second
cell type (`plasmablast`) is listed in `celltype.txt` for future use,
but doesn't have synthetic genotype data generated for it yet, so the
script skips it gracefully instead of failing.

### Reading the cell-type output

This writes three files per cell type into `out/` (see
`demo_out/CD14-positive_monocyte_*` for real reference output to
compare against):

| File | One row per | Key columns |
|---|---|---|
| `<celltype>_association.txt` | gene | `effect`, `se`, `zscore`, `pvalue` — the association test result. Unlike the tissue track's `effect_size`, `effect`/`se` here are real numbers, not `NA` — individual-level PrediXcan regresses predicted expression directly against the phenotype, which naturally produces both. |
| `<celltype>_summary.txt` | gene | `gene_name`, `n_snps_in_model`, `n_snps_used`, `pred_perf_r2`, `pred_perf_pval` — how well the weight model predicts that gene's expression, independent of this run's phenotype. `n_snps_used` is often `NA` here with the synthetic data in this run. |
| `<celltype>_predict.txt` | sample (synthetic individual) | one column per gene — that person's predicted expression value. This is intermediate output the other two files are built from; nothing you need to read row-by-row. |

`n_samples` and `status` in `association.txt` are bookkeeping (always
`200` and `NA` in this run) — not something to chase.
