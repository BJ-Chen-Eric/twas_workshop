# TWAS Workshop

**No bioinformatics background needed — this README assumes none.**

## In plain terms

Small differences in your DNA can affect how *active* a gene is — how
much of its protein product your cells actually make. This workshop
asks a simple question: **is a gene's activity level linked to a
disease or trait?** That's useful because it's one of the first steps
researchers take to figure out which genes might actually matter for a
condition, out of the ~20,000 genes in the human genome.

The method behind this is called a **TWAS** (transcriptome-wide
association study). The specific tool you'll run is called
**S-PrediXcan**. You don't need to know how either works to complete
this workshop — [`docs/method_overview.md`](./docs/method_overview.md)
explains the method itself in plain language, if you're curious, once
you've got it running.

*(For anyone who does want the technical framing: this tests whether a
gene's genetically **predicted** expression is associated with a trait,
using GWAS summary statistics — no lab measurements or individual
genetic data required.)*

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
**Prefer double-clicking to typing?** `script/mac/setup.command` /
`script\windows\setup.bat` do the exact same thing as the typed
commands above — just double-click instead:
- **Mac**: double-click `script/mac/setup.command`. If macOS shows a
  warning the first time, right-click the file → **Open** → confirm.
- **Windows**: double-click `script\windows\setup.bat` directly (it's
  already the double-clickable form). If Windows shows "Windows
  protected your PC," click **More info** → **Run anyway**.

(These warnings are normal for any script downloaded from the internet
that isn't from a registered publisher — not a sign anything's wrong.)

## What You'll Do

You'll run the analysis for two body tissues (spleen and whole blood),
using real (de-identified, summary-level) genetic data for one human
chromosome. For each tissue, you'll get back a table listing genes and
how strongly each one's activity level is linked to the trait being
studied — the higher the significance, the more that gene stands out as
worth a closer look. [`docs/method_overview.md`](./docs/method_overview.md)
explains exactly how to read that output table once you have it.

**How do I know it worked?** Compare your results against the reference
answers in [`demo_out/`](./demo_out/) — if your numbers match (or come
very close — tiny differences in the last decimal place are normal and
expected across different computers), it worked.

## What's In This Folder

- `docs/native_setup_guide.md` — full setup walkthrough (start here)
- `docs/method_overview.md` — what this analysis does and how to read
  the results, in plain language
- `docs/gwas_to_summary_stats.md` — additional info: where the input
  GWAS file itself comes from (raw genotypes → QC → imputation →
  summary statistics)
- `docs/causal_followup_methods.md` — additional info: what comes after
  a TWAS hit (MR, COLOC, SuSiE)
- `script/mac/setup.sh` (+ `setup.command`) — one-step setup on Mac
- `script/windows/setup.bat` — one-step setup on Windows
- `script/run_native.py` / `run_native.sh` — runs the analysis
- `demo_out/` — reference results, to check your own output against
- `tools/MetaXcan-master/` — the S-PrediXcan toolkit itself
  ([hakyimlab/MetaXcan](https://github.com/hakyimlab/MetaXcan))

## Important: What a Result Does *Not* Mean

A gene showing up as significant here means its *predicted* activity
level is statistically linked to the trait — it does **not** mean that
gene *causes* the trait. Genes sitting near each other on a chromosome
tend to be inherited together, so this method can sometimes point at a
gene that's simply a neighbor of the real culprit rather than the real
culprit itself. Treat any result as a lead worth investigating further,
never as a final answer on its own.
