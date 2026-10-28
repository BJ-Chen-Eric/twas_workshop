# Workshop Setup Guide

**Written for total beginners — if you've never used a terminal before,
start at the top and follow every step in order.** If you already know
what a terminal/venv/pip is, skip to [Quick version](#quick-version).

This setup needs only Python itself — nothing else to install. All toy
data (weight models and the GWAS summary-statistics file) downloads
automatically from Zenodo the first time you run setup.


---

## Quick version

For anyone already comfortable with a terminal: download this repo
(click the green **`<> Code`** button on this repo's GitHub page →
**`Download ZIP`** → unzip it — or `git clone` it, if you use git),
`cd` into the unzipped folder, then:
```bash
bash script/mac/step1_setup.sh             # Step 1: checks Python, venv, install, data, check
bash script/step2_run_native_tissue.sh     # Step 2: or venv/bin/python script/step2_run_native_tissue.py
bash script/step3_run_native_singlecell.sh # Step 3 (optional): cell-type track, synthetic data
```
Windows: `script\windows\step1_setup.bat` then
`venv\Scripts\python.exe script\step2_run_native_tissue.py`.

Package set (see `requirements.txt`): `numpy<2.0`, `pandas<2.0`, `scipy`,
`patsy`, `h5py`, `sqlalchemy<2.0`, `pyliftover`, `statsmodels`. The
toolkit (`tools/MetaXcan-master/software/`) ships in the repo; the toy
weight models (~130MB) and the GWAS file (~31MB) both download
automatically from Zenodo.

## Optional: double-click instead of typing

First, download this repo: click the green **`<> Code`** button on
this repo's GitHub page → **`Download ZIP`**, then unzip it (on Mac,
double-click the `.zip`; on Windows, right-click it → **Extract All**)
and open the resulting folder.

Steps 1-3's scripts do the exact same thing whether you type them or
double-click these:
- **Mac**: `script/mac/step1_setup.command`,
  `step2_run_native_tissue.command`,
  `step3_run_native_singlecell.command`. If macOS shows a warning the
  first time, right-click the file → **Open** → confirm.
- **Windows**: `script\windows\step1_setup.bat`,
  `step2_run_native_tissue.bat`, `step3_run_native_singlecell.bat` —
  double-click any of them directly (they're already in the
  double-clickable form). If Windows shows "Windows protected your
  PC", click **More info** → **Run anyway**.

(These warnings are normal for any script downloaded from the internet
that isn't from a registered publisher — not a sign anything's wrong.)

---

## Before you start — download the folder and open a terminal in it

1. Go to this repo's GitHub page in your web browser.
2. Click the green **`<> Code`** button, then **`Download ZIP`**.
3. Find the downloaded `.zip` file (usually in your `Downloads` folder)
   and **unzip it** — on Mac, double-click it; on Windows, right-click it
   and choose **Extract All**.
4. Put the resulting folder somewhere easy to find, e.g. your Desktop.

*(If you already know git, `git clone` works too — this is just the
no-git-required option.)*

Now open a terminal **in that folder** — your terminal's current
location needs to actually be the workshop folder, not just anywhere.

**Mac**: open **Finder**, navigate to the workshop folder, then either:
- Right-click the folder → **"New Terminal at Folder"** (if available), or
- Open Terminal normally and type `cd ` (with a trailing space, no
  Enter yet), then **drag the folder from Finder into the Terminal
  window** — it'll paste the full path — then press Enter.

**Windows**: open **File Explorer**, navigate into the workshop folder,
click the address bar at the top, type `powershell`, and press Enter —
this opens PowerShell already inside that folder.

**Linux**: same idea as Mac — `cd ` + drag, or right-click → "Open
Terminal Here" if your file manager offers it.

**Double-check you're in the right place**: type `ls` (Mac/Linux) or `dir`
(Windows) and press Enter — you should see files like `requirements.txt`
and a `script` folder listed. If not, you're in the wrong directory.

## Step 1 — Set up (run once)

**Mac**:
```bash
bash script/mac/step1_setup.sh
```
**Windows**:
```powershell
script\windows\step1_setup.bat
```

This single script (no typing anything else needed) — **including
checking whether Python is even installed**, so this is genuinely the
only command you need to run:
1. Checks for Python. If it's missing, it offers to install **Python
   3.11 specifically** (not just "whatever's latest"), asking for your
   confirmation first since this needs your password: on Mac, via
   Homebrew (installing Homebrew first too, if needed); on Windows, via
   `winget`. If you say no, it prints a manual install link instead and
   stops — re-run the same command once Python's in.
2. Creates an isolated Python environment (`venv/`) — keeps everything
   below from touching/conflicting with anything else on your computer.
3. Installs the required packages into it.
4. Downloads the toy data (weight models and GWAS file) from Zenodo.
5. Checks everything is actually ready, and tells you clearly if
   something's missing.

It'll print progress as it goes. The first run takes a few minutes
(downloading packages + data); safe to re-run any time — it skips
whatever's already done, and automatically cleans up and starts fresh
if an earlier attempt failed partway through.

**If it prints any `MISSING` lines at the end**, see
[Troubleshooting](#troubleshooting) below.

## Step 2 — Run the main analysis (tissue-level)

Double-click works here too:
- **Mac**: double-click `script/mac/step2_run_native_tissue.command`.
- **Windows**: double-click `script\windows\step2_run_native_tissue.bat`.

Or, typed:

**Mac / Linux**:
```bash
bash script/step2_run_native_tissue.sh
```
**Windows** (or anywhere you'd rather not use bash):
```powershell
venv\Scripts\python.exe script\step2_run_native_tissue.py
```
```bash
venv/bin/python script/step2_run_native_tissue.py    # Mac/Linux equivalent, if preferred
```

This runs the actual TWAS analysis (S-PrediXcan) for both tissues,
writing results into a new `out/` folder.

## Step 3 — Optional: the cell-type track

Double-click `script/mac/step3_run_native_singlecell.command` /
`script\windows\step3_run_native_singlecell.bat`, or run
`script/step3_run_native_singlecell.sh`/`.py` the typed way — same as
Step 2. This uses a different method (individual-level `PrediXcan.py`)
against **synthetic** genotype data — not real individuals, simulated
from real allele frequencies (see
`script/step3_run_native_singlecell.py`'s comments for why). Its
results are close to statistical noise by design: this track
demonstrates the individual-level pipeline running, not a real
biological finding. Treat it as a bonus.

If you run either Step 2 or Step 3 before Step 1, you'll get a clear
"run setup first" message instead of a confusing error.

---

## Troubleshooting

- **Step 1 says Python wasn't found**: it'll print a link and instructions
  right there — install Python, open a new terminal, and run Step 1 again.
- **On Windows, Step 1 fails with "Microsoft Visual C++ 14.0 or greater
  is required"**: this means it ended up building on Python 3.12+
  instead of 3.11 (pandas needs a C/C++ compiler to build on 3.12+,
  which most computers don't have). Install Python 3.11 manually
  (`winget install -e --id Python.Python.3.11`) and re-run setup with
  `py -3.11 script\step1_setup.py` specifically — don't spend workshop
  time installing a C++ compiler.
- **Permission/security warnings when double-clicking any `.command`
  or `.bat` file**: expected for downloaded scripts, see the note
  above — or just use the typed-command version instead, which doesn't
  trigger these.
- **Downloading the toy data fails with "Too Many Requests" or a
  gateway timeout**: Zenodo (where the toy data is hosted) is a shared
  public service and occasionally rate-limits or times out, especially
  if many people on the same network run setup at once (e.g. everyone
  in the workshop room at the same time). Setup already waits and
  retries automatically — if it still fails after that, just wait a
  minute and re-run Step 1; it skips any files already downloaded and
  only retries what's missing.
- **pip starts failing with a confusing "Invalid version" error**: this
  can happen if the workshop folder lives inside a cloud-synced folder
  (iCloud Drive, Dropbox, OneDrive, Google Drive) — the sync service can
  create conflict-duplicate files inside `venv/` while pip is writing to
  it, corrupting a package's version info badly enough to block further
  installs. Fix: delete the `venv` folder entirely and re-run Step 1 to
  rebuild it from scratch. If it keeps happening, move this folder
  outside the cloud-synced location.
- **Something else looks wrong**: re-run Step 1
  (`bash script/mac/step1_setup.sh` / `script\windows\step1_setup.bat`)
  — it's safe to run repeatedly, and re-reports exactly what's missing.
