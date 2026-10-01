# Additional Information: After a TWAS Hit — Testing Causality Further

[`method_overview.md`](./method_overview.md) explains why a significant
TWAS result does **not** by itself prove a gene causes the trait — it
could just be sitting near the real causal gene and sharing its genetic
signal (linkage disequilibrium). This page briefly introduces the
methods researchers actually use to dig further into a TWAS hit before
believing it. None of this is required to complete the workshop — it's
here for anyone who wants to know "what would come next."

## The question each method answers

| Method | Question it answers |
|---|---|
| **Mendelian Randomization (MR)**, specifically MR-Egger | If a gene's expression really does causally affect the trait, does the genetic evidence hold up as a valid "instrument" for that causal claim — and is there detectable pleiotropy (the genetic variants affecting the trait through some *other* path, not through this gene's expression)? |
| **COLOC** (colocalization) | Are the GWAS signal (trait association) and the eQTL signal (expression association) at this locus actually driven by the *same* underlying causal variant, or just two *different* nearby variants that happen to be correlated? |
| **SuSiE** (fine-mapping) | At loci with more than one independent signal, which specific variant(s) are most likely causal, separately for the GWAS and the eQTL evidence — a more precise version of what COLOC checks with a single-signal assumption. |

## Mendelian Randomization (MR-Egger)

MR treats genetic variants as a kind of natural experiment: since your
genotype is fixed at conception (not influenced by anything that happens
afterward), a variant that affects gene expression can be used as an
"instrument" to test whether that expression causally affects the trait
— similar in spirit to a randomized trial, without actually randomizing
anything. **MR-Egger** specifically is a version of this that also tests
for **pleiotropy** — whether the instrument (the variant) might be
affecting the trait through some route other than the gene expression
being tested, which would invalidate the causal interpretation. It
reports two numbers: a causal-effect estimate, and an **intercept
p-value** — a significant intercept is the actual pleiotropy warning
sign, independent of whether the causal estimate itself looks
significant.

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

## Want to see this actually implemented?

These three methods, run together as a single per-gene pipeline on
real TWAS-significant genes, are implemented in the project's own
`command_MR_pp.R` (not included in this workshop folder — it's part of
the internal development material, and needs real genotype/eQTL
reference data this workshop doesn't ship with). Ask the workshop
organizer if you'd like to see it.
