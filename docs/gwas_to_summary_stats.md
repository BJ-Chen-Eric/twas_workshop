# Additional Information: Where Does a GWAS Summary-Statistics File Come From?

This workshop starts from an already-computed GWAS summary-statistics
file (`gwas_ss/chr10_imputed_gwas.pheno.glm.logistic.hybrid`) — one row
per genetic variant (SNP), with a test statistic for how strongly that
variant associates with the trait. You don't need to reproduce any of
this to complete the workshop; it's here for anyone curious about how
that starting file actually gets made, starting from raw genotyped
samples.

## The short version

```
raw genotyped samples (per cohort)
        │  quality control (QC)
        ▼
clean, merged cohort
        │  population-structure & relatedness correction
        ▼
QC'd, GWAS-ready dataset
        │  imputation against a reference panel
        ▼
imputed genotypes (many more variants than were actually measured)
        │  association test (e.g. logistic regression, one SNP at a time)
        ▼
GWAS summary statistics  ← this workshop starts here
```

## Why QC first?

Raw genotyping data has real, mundane problems: samples with
mismatched/unknown recorded sex, genotyping failures at some variants,
duplicate or unexpectedly related individuals, and so on. Each is
checked and filtered before anything else happens — e.g. comparing each
sample's recorded sex against what its genotypes imply, dropping
variants with too much missing data or that violate
Hardy-Weinberg-equilibrium expectations, and removing samples that are
secretly duplicates or close relatives of someone else in the dataset
(relatedness inflates false associations if left in).

## Why correct for population structure?

If people with ancestry group A happen to also have more of the trait
in your sample (for reasons unrelated to any specific gene — just
population history), *any* variant that differs in frequency between
ancestry groups will look falsely associated with the trait. Computing
principal components (PCA) on the genotypes and including them as
covariates in the association test — plus removing related
individuals via relatedness estimation (e.g. the KING method) — is the
standard way to control for this.

## Why impute?

A genotyping array or sequencing run only directly measures a subset of
all the variants that exist in the genome. **Imputation** statistically
fills in the rest: using a large, already-fully-sequenced reference
panel (where the correlation structure between nearby variants —
linkage disequilibrium — is well characterized), it predicts the most
likely genotype at untyped positions for each of your samples, based on
which reference haplotypes their directly-measured genotypes most
resemble. This is also why the GWAS summary-stats file has so many more
rows (variants) than the original genotyping array measured directly.

## From imputed genotypes to the summary-statistics file

Once the dataset is QC'd, structure-corrected, and imputed, the actual
GWAS step tests each variant one at a time: does this variant's genotype
(or imputed dosage) associate with the trait, after adjusting for the
covariates above? The result is one row per variant — effect direction,
a test statistic (e.g. Z-score or odds ratio), and a p-value. That table
*is* the GWAS summary-statistics file — exactly the kind of file
`run_native.py`/`run_native.sh` reads in this workshop, just for a real
trait and a real (QC'd, imputed) cohort instead of the toy setup here.

## Want the real, detailed version?

This page is deliberately a conceptual overview, not a command-by-command
recipe — the full pipeline (exact PLINK/bcftools/Beagle commands, every
QC threshold used) lives in the project's internal development
documentation, which assumes more background and isn't part of this
curated workshop folder. Ask the workshop organizer if you want to see
it.
