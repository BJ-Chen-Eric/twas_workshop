# Workshop Setup Guide

**Written for total beginners — if you've never used a terminal before,
start at the top and follow every step in order.** If you already know
what a terminal/venv/pip is, skip to [Quick version](#quick-version).

This setup needs only Python itself — nothing else to install. All toy
data (weight models and the GWAS summary-statistics file) downloads
automatically from Zenodo the first time you run setup.

---

## Step 1 — Download this workshop folder

1. Go to this repo's GitHub page in your web browser.
2. Click the green **`<> Code`** button, then **`Download ZIP`**.
3. Find the downloaded `.zip` file (usually in your `Downloads` folder)
   and **unzip it** — on Mac, double-click it; on Windows, right-click it
   and choose **Extract All**.
4. Put the resulting folder somewhere easy to find, e.g. your Desktop.

*(If you already know git, `git clone` works too — this is just the
no-git-required option.)*

## Step 2 — Open a terminal *in the workshop folder*

You need your terminal's current location to actually be the folder from
Step 1, not just anywhere.

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

## Step 3 — Run the one setup script

**Mac**:
```bash
bash script/mac/setup.sh
```
**Windows**:
```powershell
script\windows\setup.bat
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

## Step 4 — Run the workshop analysis

**Mac / Linux**:
```bash
bash script/run_native_tissue.sh
```
**Windows** (or anywhere you'd rather not use bash):
```powershell
venv\Scripts\python.exe script\run_native_tissue.py
```
```bash
venv/bin/python script/run_native_tissue.py    # Mac/Linux equivalent, if preferred
```

This runs the actual TWAS analysis (S-PrediXcan) for both tissues,
writing results into a new `out/` folder.

**Optional — the cell-type track**: run `script/run_native_singlecell.sh`
(or `.py` on Windows) the same way. This uses a different method
(individual-level `PrediXcan.py`) against **synthetic** genotype data —
not real individuals, simulated from real allele frequencies (see
`script/run_native_singlecell.py`'s comments for why). Its results are
close to statistical noise by design: this track demonstrates the
individual-level pipeline running, not a real biological finding. Treat
it as a bonus.

---

## Quick version

For anyone already comfortable with a terminal:
```bash
# 1. Download + unzip this repo, cd into it, then:
bash script/mac/setup.sh             # checks Python, venv, install, data, check
bash script/run_native_tissue.sh     # or: venv/bin/python script/run_native_tissue.py
bash script/run_native_singlecell.sh # optional cell-type track (synthetic data)
```
Windows: `script\windows\setup.bat` then
`venv\Scripts\python.exe script\run_native_tissue.py`.

Package set (see `requirements.txt`): `numpy<2.0`, `pandas<2.0`, `scipy`,
`patsy`, `h5py`, `sqlalchemy<2.0`, `pyliftover`, `statsmodels`. The
toolkit (`tools/MetaXcan-master/software/`) ships in the repo; the toy
weight models (~130MB) and the GWAS file (~31MB) both download
automatically from Zenodo.

## Optional: double-click instead of typing

Step 3's scripts do the exact same thing whether you type them or
double-click these:
- **Mac**: double-click `script/mac/setup.command`. If macOS shows a
  warning the first time, right-click the file → **Open** → confirm.
- **Windows**: double-click `script\windows\setup.bat` directly (it's
  already the double-clickable form). If Windows shows "Windows
  protected your PC", click **More info** → **Run anyway**.

(These warnings are normal for any script downloaded from the internet
that isn't from a registered publisher — not a sign anything's wrong.)

## Troubleshooting

- **Step 3 says Python wasn't found**: it'll print a link and instructions
  right there — install Python, open a new terminal, and run Step 3 again.
- **On Windows, setup fails with "Microsoft Visual C++ 14.0 or greater
  is required"**: this means it ended up building on Python 3.12+
  instead of 3.11 (pandas needs a C/C++ compiler to build on 3.12+,
  which most computers don't have). Install Python 3.11 manually
  (`winget install -e --id Python.Python.3.11`) and re-run setup with
  `py -3.11 script\setup.py` specifically — don't spend workshop time
  installing a C++ compiler.
- **Permission/security warnings when double-clicking `setup.command`
  or `setup.bat`**: expected for downloaded scripts, see the note above —
  or just use the typed-command version in Step 3 instead, which doesn't
  trigger these.
- **pip starts failing with a confusing "Invalid version" error**: this
  can happen if the workshop folder lives inside a cloud-synced folder
  (iCloud Drive, Dropbox, OneDrive, Google Drive) — the sync service can
  create conflict-duplicate files inside `venv/` while pip is writing to
  it, corrupting a package's version info badly enough to block further
  installs. Fix: delete the `venv` folder entirely and re-run Step 3 to
  rebuild it from scratch. If it keeps happening, move this folder
  outside the cloud-synced location.
- **Something else looks wrong**: re-run Step 3 (`bash script/mac/setup.sh` /
  `script\windows\setup.bat`) — it's safe to run repeatedly, and re-reports
  exactly what's missing.

## Why not Docker?

Docker was the original plan and did work — but installing Docker Desktop
itself turned out to be slow and complicated in practice, and once it was
clear the actual analysis only needs a handful of plain `pip`-installable
Python packages (no conda, nothing exotic), a virtual environment turned
out to do the identical job with far less to install and far less that
can go wrong.
