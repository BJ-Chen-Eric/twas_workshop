# Additional Information: After a TWAS Hit — Testing Causality Further

[`2_method_overview.md`](./2_method_overview.md) explains why a significant
TWAS result does **not** by itself prove a gene causes the trait — it
could just be sitting near the real causal gene and sharing its genetic
signal (linkage disequilibrium). This page briefly introduces the
methods researchers actually use to dig further into a TWAS hit before
believing it. None of this is required to complete the workshop — it's
here for anyone who wants to know "what would come next."

## The question each method answers

| Method | Question it answers |
|---|---|
| **Mendelian Randomization (MR)** — IVW for the estimate, MR-Egger as its pleiotropy check | If a gene's expression really does causally affect the trait, does the genetic evidence hold up as a valid "instrument" for that causal claim — and is there detectable pleiotropy (the genetic variants affecting the trait through some *other* path, not through this gene's expression)? |
| **COLOC** (colocalization) | Are the GWAS signal (trait association) and the eQTL signal (expression association) at this locus actually driven by the *same* underlying causal variant, or just two *different* nearby variants that happen to be correlated? |
| **SuSiE** (fine-mapping) | At loci with more than one independent signal, which specific variant(s) are most likely causal, separately for the GWAS and the eQTL evidence — a more precise version of what COLOC checks with a single-signal assumption. |
| **SMR + HEIDI** | A faster, single-SNP alternative to COLOC: is the GWAS-trait effect implied by this locus's single strongest eQTL consistent with that SNP acting through one shared causal variant (HEIDI non-significant), or is it more consistent with two separate, merely-linked variants (HEIDI significant)? |

## Mendelian Randomization (IVW + MR-Egger)

MR treats genetic variants as a kind of natural experiment: since your
genotype is fixed at conception (not influenced by anything that happens
afterward), a variant that affects gene expression can be used as an
"instrument" to test whether that expression causally affects the trait
— similar in spirit to a randomized trial, without actually randomizing
anything.

The main causal-effect estimate is usually produced by a method called
**IVW** (inverse-variance weighted) — it's the default workhorse, but
it assumes none of the instruments have pleiotropy (see below).
**MR-Egger** is run alongside it, not instead of it: it's a sensitivity
check on that same estimate, specifically testing for **pleiotropy** —
whether an instrument (variant) might be affecting the trait through
some route other than the gene expression being tested, which would
invalidate IVW's causal interpretation. MR-Egger reports two numbers: a
causal-effect estimate of its own, and an **intercept p-value** — a
significant intercept is the actual pleiotropy warning sign,
independent of whether the causal estimate itself looks significant.

IVW and MR-Egger aren't the only options — both make a specific
assumption about *how* pleiotropy could show up, and other methods
relax that assumption differently:
- **Weighted median**: takes the median of the individual
  instrument-level causal estimates (weighted by precision), instead
  of their average like IVW does. It stays valid even if some
  instruments are pleiotropic, as long as more than half the weight
  comes from valid ones — a different, often more realistic
  assumption than "none are pleiotropic" (IVW) or "pleiotropy is
  uncorrelated with instrument strength" (Egger).
- **MR-PRESSO**: looks for individual instruments that fit the overall
  pattern unusually badly (outliers), flags/removes them, then
  re-estimates the causal effect without them — plus a global test for
  whether pleiotropy is present at all across the instrument set.

All of these exist because no single method's assumption about
pleiotropy is guaranteed to hold — in practice, researchers often run
several and check whether the causal conclusion survives.

*(A practical catch specific to the TWAS setting: MR-Egger needs
several independent genetic instruments — conventionally at least 3 —
to fit both the effect estimate and the intercept. A gene's cis region
often has just one strong, dominant eQTL with no other independent
signal nearby, which leaves too few instruments to run MR-Egger at
all. COLOC doesn't have this requirement — it works directly off the
full signal at the locus rather than needing multiple independent
instruments — which is why COLOC tends to be the first method reached
for in that single-eQTL situation.)*

## COLOC (colocalization)

A TWAS hit means two signals overlap at a locus: the GWAS association
(trait ~ genotype) and the eQTL association (expression ~ genotype) used
to build the prediction model. COLOC asks whether those two signals are
most consistent with **one shared causal variant** driving both, or
**two distinct variants** that just happen to be near each other (and
therefore correlated, since nearby variants are often inherited
together). It's a Bayesian method — the output is a set of posterior
probabilities for five possible explanations, and the one that matters
most is **PP.H4**: the probability that a single variant explains both
signals. A low PP.H4 is a warning that the TWAS hit's gene might not be
the real story.

## SuSiE (fine-mapping)

COLOC's standard form assumes at most one causal signal per side. Real
loci sometimes have more than one independent causal variant nearby.
**SuSiE** ("Sum of Single Effects") fine-maps a locus by identifying a
small number of **credible sets** — each one a small group of variants
that together are very likely to contain a causal one, without
necessarily pinning down which single variant it is. Running SuSiE
separately on the GWAS and eQTL summary statistics for a locus, then
comparing the credible sets between them (`coloc.susie`), gives a more
precise colocalization answer than plain COLOC when a locus is
genetically complex. This step is also the most fragile in practice —
fine-mapping methods are known to need careful handling on real,
imperfect linkage-disequilibrium data, not just a single function call.

## SMR + HEIDI

**SMR** (Summary-data-based Mendelian Randomization) is a lighter-weight
alternative to COLOC: instead of modeling the full signal at a locus,
it uses only the single strongest eQTL SNP for a gene as a one-SNP
genetic instrument, in the same MR logic described above (trait effect
= eQTL's effect on expression × expression's effect on trait). Being
single-SNP and summary-stats-only, it's fast — this is the same
family of logic as basic MR, just applied directly to one eQTL rather
than needing multiple independent instruments like MR-Egger does.

On its own, SMR has the same blind spot as basic MR: it can't tell
"this gene's expression really is causal" apart from "a *different*
nearby causal variant just happens to be correlated with this eQTL."
**HEIDI** (HEterogeneity In Dependent Instruments) is the companion
test that addresses exactly that: it checks several SNPs correlated
with the top eQTL and asks whether they all imply a similar SMR
estimate. If they do (HEIDI **non**-significant), that's consistent
with one shared causal variant — the same conclusion a high COLOC
PP.H4 would support. If the estimates disagree (HEIDI significant),
that points to two separate, merely-linked variants instead. This
method is already part of this project's own real pipeline
(`script/smr/*`, outside this curated workshop folder) — it predates
COLOC's popularity and is still commonly used as a quick first pass
before (or instead of) the heavier Bayesian machinery COLOC/SuSiE use.

## A related but different question: LD score regression

Every method above answers a question about **one specific locus**:
does this one gene's eQTL signal and the GWAS signal there share a
causal variant? **LD score regression (LDSC)** answers something
different and genome-wide, not locus-specific at all: using nothing
but GWAS summary statistics and a reference panel's LD structure, it
estimates (1) **SNP-heritability** — how much of a trait's variance is
explained by common genetic variants overall, and (2) **genetic
correlation** between two different GWAS traits — whether they share
genetic architecture across the whole genome, not at any one gene.

It doesn't slot into the table above because it can't tell you
anything about a single TWAS hit. Where it actually shows up around a
TWAS: confirming a GWAS has enough real heritable signal to be worth
running a TWAS on in the first place, or asking whether the trait a
TWAS was run on is genetically correlated with some other trait at a
genome-wide level. It's a different tool for a different, broader
question — not a per-hit follow-up like everything else on this page.
