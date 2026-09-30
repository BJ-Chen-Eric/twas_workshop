# TWAS Workshop

A hands-on introduction to transcriptome-wide association study (TWAS)
analysis — using **S-PrediXcan** to test whether a gene's genetically
predicted expression is associated with a trait, directly from GWAS
summary statistics.

## Get Started

**New to the command line, or unsure how to even download this?** Start
at [`docs/native_setup_guide.md`](./docs/native_setup_guide.md) — it
walks through everything from zero: downloading this repo, opening a
terminal, and running the one setup script. Works on Mac, Windows, and
Linux.

### 1. Download this repo
Click the green **`<> Code`** button above → **`Download ZIP`**, then
unzip it (or `git clone` this repo, if you already use git).

### 2. Open a terminal in the unzipped folder
See [`docs/native_setup_guide.md`](./docs/native_setup_guide.md) Step 2
if you're not sure how — it covers Mac, Windows, and Linux.

### 3. Run setup, then the analysis
**Mac**:
```bash
bash script/mac/setup.sh        # one script: checks Python, creates a
                                 # venv, installs packages, downloads
                                 # toy data, checks everything's ready
bash script/run_native.sh       # runs the actual analysis
```
**Windows**:
```powershell
script\windows\setup.bat
venv\Scripts\python.exe script\run_native.py
```
(Prefer double-clicking to typing? `script/mac/setup.command` and
`script\windows\setup.bat` both work that way too — see the guide.)

## What You'll Do

Run S-PrediXcan for two tissues (Spleen, Whole_Blood) against a real
chromosome's worth of GWAS summary statistics, and get a table of
gene-level association results for each — see
[`docs/method_overview.md`](./docs/method_overview.md) for what the
method actually does and how to read the output.

## What's In This Folder

- `docs/native_setup_guide.md` — full setup walkthrough
- `docs/method_overview.md` — what S-PrediXcan does and why
- `script/mac/setup.sh` (+ `setup.command`) — one-step setup on Mac
- `script/windows/setup.bat` — one-step setup on Windows
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
