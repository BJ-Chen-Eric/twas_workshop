# TWAS Workshop

A hands-on introduction to transcriptome-wide association study (TWAS)
analysis — using **S-PrediXcan** to test whether a gene's genetically
predicted expression is associated with a trait, directly from GWAS
summary statistics.

## Get Started

New to the command line? No problem — [`docs/native_setup_guide.md`](./docs/native_setup_guide.md)
walks through everything from scratch: downloading this folder, opening a
terminal, and running the one setup script. Works on Mac, Windows, and
Linux.

Quick version, if you're already comfortable with a terminal:
```bash
python3 script/setup.py        # one script: creates a venv, installs
                                # packages, downloads the toy data, and
                                # checks everything's ready
bash script/run_native.sh       # runs the actual analysis
```
(Windows: `python script\setup.py`, then
`venv\Scripts\python.exe script\run_native.py`.)

## What You'll Do

Run S-PrediXcan for two tissues (Spleen, Whole_Blood) against a real
chromosome's worth of GWAS summary statistics, and get a table of
gene-level association results for each — see
[`docs/method_overview.md`](./docs/method_overview.md) for what the
method actually does and how to read the output.

## What's In This Folder

- `docs/native_setup_guide.md` — full setup walkthrough
- `docs/method_overview.md` — what S-PrediXcan does and why
- `script/setup.py` — one-step setup (venv + packages + toy data + check)
- `script/run_native.py` / `run_native.sh` — runs the analysis
- `tools/MetaXcan-master/` — the S-PrediXcan toolkit itself
  ([hakyimlab/MetaXcan](https://github.com/hakyimlab/MetaXcan))

## Important Interpretation Note

TWAS estimates the association between a trait and *genetically
predicted* gene expression — it does not measure expression directly, and
a significant result does not by itself prove the gene is causal: shared
eQTLs and linkage disequilibrium with the true causal variant can
implicate the wrong gene. Treat results as a starting point for follow-up
investigation, not a final answer.
