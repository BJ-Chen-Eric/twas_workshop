# Workshop Setup Guide

**Written for total beginners — if you've never used a terminal before,
start at the top and follow every step in order.** If you already know
what a terminal/venv/pip is, skip to [Quick version](#quick-version).

**Status (2026-09-30): validated on Mac (Python 3.9, Python 3.12 ARM) and
Linux (Python 3.10)** — all three reproduced the reference output (the
Python 3.12 run matches to within floating-point rounding noise from a
different BLAS backend — same genes, same order, same signs, only
last-digit differences). Windows hasn't been tested yet (flagged below
where it matters). All toy data, including the chr10 GWAS file, now
lives on Zenodo
([weights: record 22822753](https://zenodo.org/records/22822753),
[GWAS: record 22866999](https://zenodo.org/records/22866999)) —
`script/setup.py` downloads both automatically.

Docker was tried and dropped entirely (2026-09-18) — this native setup
needs only Python itself, nothing else to install.

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
1. Checks for Python. If it's missing, it'll offer to install
   **Python 3.11 specifically** (not just "whatever's latest"), asking
   yes/no first since this needs your password/confirmation: on Mac,
   via Homebrew `python@3.11` (installing Homebrew first too, if
   needed); on Windows, via `winget install ... Python.Python.3.11`. If
   you say no, it prints a manual install link instead and stops —
   re-run the same command once Python's in. *(This auto-install offer
   hasn't been tested hands-on on a genuinely Python-less machine yet —
   see `discussion.md` 2026-09-22/2026-09-30; if it misbehaves, use the
   manual link it also prints.)*
   **Why 3.11 specifically**: `pandas<2.0` (pinned below) has no
   ready-made install package for Python 3.12+ on any platform, so
   setup has to compile it — confirmed working on Mac (2026-09-30), but
   compiling on Windows additionally needs a C/C++ compiler most
   computers don't have. Already on 3.12+? It'll likely still work on
   Mac/Linux; on Windows it's untested — see Troubleshooting below.
2. Creates an isolated Python environment (`venv/`) — keeps everything
   below from touching/conflicting with anything else on your computer.
3. Installs the required packages into it.
4. Downloads the toy data (weight models) from Zenodo.
5. Checks everything is actually ready, and tells you clearly if
   something's missing.

It'll print progress as it goes. The first run takes a few minutes
(downloading packages + data); safe to re-run any time — it skips
whatever's already done.

**If it prints any `MISSING` lines at the end**, see
[Troubleshooting](#troubleshooting) below.

## Step 4 — Run the workshop analysis

**Mac / Linux**:
```bash
bash script/run_native.sh
```
**Windows** (or anywhere you'd rather not use bash):
```powershell
venv\Scripts\python.exe script\run_native.py
```
```bash
venv/bin/python script/run_native.py    # Mac/Linux equivalent, if preferred
```

This runs the actual TWAS analysis (S-PrediXcan) for both tissues,
writing results into a new `out/` folder.

---

## Quick version

For anyone already comfortable with a terminal:
```bash
# 1. Download + unzip this repo, cd into it, then:
bash script/mac/setup.sh        # checks Python, venv, install, data, check
bash script/run_native.sh       # or: venv/bin/python script/run_native.py
```
Windows: `script\windows\setup.bat` then
`venv\Scripts\python.exe script\run_native.py`.

Package set (see `requirements.txt`): `numpy<2.0`, `pandas<2.0`, `scipy`,
`patsy`, `h5py`, `sqlalchemy<2.0`. The toolkit
(`tools/MetaXcan-master/software/`) ships in the repo; the toy weight
models (~130MB, [record 22822753](https://zenodo.org/records/22822753))
and the GWAS file (~31MB,
[record 22866999](https://zenodo.org/records/22866999)) both download
automatically.

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
- **Building `pandas` fails on Python 3.12** (`pkg_resources` or
  `Cython` missing): **resolved on Mac 2026-09-30**, confirmed via a
  real, complete run all the way through the actual analysis —
  `script/setup.py` pins `setuptools<81`, `numpy`, and `Cython<3` into
  the venv, then builds pandas with `--no-build-isolation`. If you still
  hit this on Mac/Linux, something changed since — flag it rather than
  trying to self-resolve mid-workshop.
- **On Windows, Python 3.12+ fails with "Microsoft Visual C++ 14.0 or
  greater is required"**: **confirmed on a real Windows run,
  2026-09-30** — building pandas from source needs a C/C++ compiler
  (Microsoft C++ Build Tools), which most computers don't have. `setup.bat`
  now checks for this and automatically uses a side-installed Python 3.11
  for the venv if one's available (via the `py` launcher), and prints a
  clear message either way — but this detection logic itself is
  **untested hands-on** (no Windows machine available to verify the
  batch script runs as written). If it doesn't catch it automatically:
  install **Python 3.11** (`winget install -e --id Python.Python.3.11`,
  pandas has a ready-made package for it, nothing to compile) and
  re-run setup with `py -3.11 script\setup.py` specifically — don't
  spend workshop time installing a C++ compiler. *(You don't need to
  delete the `venv` folder yourself first — as of 2026-09-30, setup now
  removes it automatically whenever installation fails partway through,
  so re-running always starts clean.)*
- *(2026-09-30: `bgen-reader`/`cyvcf2` were removed from
  `requirements.txt` entirely — they were never actually used by
  anything this workshop runs (only needed for a different,
  individual-level genotype pipeline), and both had real, unfixable
  installation problems on Python 3.12/this platform. If you see old
  guidance mentioning them, it's stale.)*
- **Permission/security warnings when double-clicking `setup.command`
  or `setup.bat`**: expected for downloaded scripts, see the note above —
  or just use the typed-command version in Step 3 instead, which doesn't
  trigger these.
- **Something else looks wrong**: re-run Step 3 (`bash script/mac/setup.sh` /
  `script\windows\setup.bat`) — it's safe to run repeatedly, and re-reports
  exactly what's missing.

## Why not Docker?

Docker was the original plan and did work — but installing Docker Desktop
itself turned out to be slow and complicated in practice, and once it was
clear the actual analysis only needs 8 plain `pip`-installable Python
packages (no conda, nothing exotic), a virtual environment turned out to
do the identical job with far less to install and far less that can go
wrong. Docker was dropped entirely (2026-09-18) rather than kept as a
fallback, since it wasn't pulling its weight.
