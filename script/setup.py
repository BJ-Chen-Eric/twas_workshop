#!/usr/bin/env python3
"""
ONE-STOP WORKSHOP SETUP — run this first.

Does everything: creates a virtual environment, installs the required
packages into it, downloads the toy data, and checks everything is ready.
Pure standard library only (no dependencies of its own), so it runs with
any stock Python 3 install on Mac, Windows, or Linux — see
docs/native_setup_guide.md for the full beginner-friendly walkthrough
(how to install Python, open a terminal, etc., if you need that).

Usage (from a terminal, after downloading/unzipping this repo):
    python3 script/setup.py      (Mac/Linux)
    python script\\setup.py       (Windows)

Safe to re-run — every step skips work that's already done.
"""
import os
import shutil
import subprocess
import sys
import urllib.request

WORKSHOP_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VENV_DIR = os.path.join(WORKSHOP_DIR, "venv")
IS_WINDOWS = os.name == "nt"
VENV_PYTHON = os.path.join(VENV_DIR, "Scripts" if IS_WINDOWS else "bin",
                            "python.exe" if IS_WINDOWS else "python")

# Zenodo deposit: "Finding risk genes for complex diseases at post-GWAS
# era, toy data" — https://zenodo.org/records/22822753
ZENODO_RECORD = "22822753"
ZENODO_BASE = f"https://zenodo.org/api/records/{ZENODO_RECORD}/files"

# (zenodo key, local destination, expected size in bytes). Filenames and
# sizes confirmed via the Zenodo API (case-sensitive) — verified present
# in record 22822753. Size is checked against any existing file before
# skipping a re-download — a truncated/corrupt download (e.g. a dropped
# connection, see discussion.md 2026-09-30) would otherwise be mistaken
# for "already downloaded" forever on re-runs.
DATA_FILES = [
    ("en_Spleen.db", "tissue_twas_weight/en_Spleen.db", 29024256),
    ("en_Spleen.txt.gz", "tissue_twas_weight/en_Spleen.txt.gz", 30844880),
    ("en_Whole_Blood.db", "tissue_twas_weight/en_Whole_Blood.db", 33234944),
    ("en_Whole_Blood.txt.gz", "tissue_twas_weight/en_Whole_Blood.txt.gz", 41012126),
    # Cell-type weight models — used by Eric's script/run_native_sc.sh.
    # Folder/filenames match what that script expects (celltype_twas_weight/,
    # no "en_" prefix, per Eric's 2026-09-22 edit). STILL BLOCKED though:
    # there is no .txt.gz covariance file for either on Zenodo, and
    # S-PrediXcan requires one (MatrixManager.load_matrix_manager crashes
    # on a None path) — see discussion.md 2026-09-22.
    ("CD14-positive_monocyte.db", "celltype_twas_weight/CD14-positive_monocyte.db", 4005888),
    ("plasmablast.db", "celltype_twas_weight/plasmablast.db", 4075520),
]

# GWAS summary-statistics file — separate Zenodo record (added 2026-09-22).
GWAS_ZENODO_RECORD = "22866999"
GWAS_ZENODO_BASE = f"https://zenodo.org/api/records/{GWAS_ZENODO_RECORD}/files"
GWAS_FILENAME = "chr10_imputed_gwas.pheno.glm.logistic.hybrid"
GWAS_FILE_REL = f"gwas_ss/{GWAS_FILENAME}"
GWAS_FILE_SIZE = 32650046

# tissue.txt / celltype.txt are tiny and fixed (match the actual toy-data
# scope, see docs/data_requirements.md) — generated directly rather than
# fetched. celltype.txt feeds Eric's script/run_native_sc.sh.
TISSUE_FILE_CONTENT = "Spleen\nWhole_Blood\n"
CELLTYPE_FILE_CONTENT = "CD14-positive_monocyte\nplasmablast\n"


def step(msg):
    print(f"\n==> {msg}")


def run(cmd):
    print(f"    $ {' '.join(cmd)}")
    subprocess.run(cmd, check=True)


def check_python_version():
    step("Checking Python version")
    print(f"    {sys.version}")
    if sys.version_info < (3, 9):
        print("    WARNING: Python 3.9+ recommended (validated on 3.9 and "
              "3.10). Continuing anyway, but if something below fails, "
              "installing a newer Python is the first thing to try.")
    elif sys.version_info >= (3, 12):
        print("    NOTE: pandas 1.5.3 (pinned below) has no prebuilt "
              "install package for Python 3.12+, so the next step builds "
              "it from source. Confirmed working on Mac as of "
              "2026-09-30, but building from source on Windows also "
              "needs a C/C++ compiler (Microsoft C++ Build Tools) that "
              "most computers don't have installed — untested on "
              "Windows. If this step fails and you have a choice,")
        if IS_WINDOWS:
            print("    installing Python 3.11 instead avoids the whole "
                  "issue (pandas has a ready-made package for it, no "
                  "compiling needed) — see "
                  "https://www.python.org/downloads/release/python-3119/")
        else:
            print("    installing Python 3.11 instead avoids needing "
                  "to build pandas from source at all.")


def create_venv():
    step("Creating virtual environment (./venv)")
    if os.path.exists(VENV_PYTHON):
        print("    Already exists, skipping.")
        return
    run([sys.executable, "-m", "venv", VENV_DIR])


def remove_venv(reason):
    step(f"Removing ./venv ({reason})")
    if os.path.exists(VENV_DIR):
        shutil.rmtree(VENV_DIR)
        print(f"    Removed {VENV_DIR}.")
    else:
        print("    Already gone.")


def install_requirements():
    step("Installing required packages into ./venv")
    req_file = os.path.join(WORKSHOP_DIR, "requirements.txt")
    run([VENV_PYTHON, "-m", "pip", "install", "-q", "--upgrade", "pip"])
    # pandas<2.0 has no prebuilt wheel on Python 3.12+, so pip builds it
    # from source. Pinning an old setuptools INTO THE VENV isn't enough
    # on its own (confirmed 2026-09-30, Eric's real run): a normal
    # (isolated) build fetches its own FRESH setuptools into a throwaway
    # build env regardless of what's pinned in the venv, and modern
    # setuptools (81+) removed pkg_resources, which pandas 1.5.3's
    # legacy setup.py needs. Fix: install numpy + an old setuptools into
    # the venv first, then build pandas specifically with
    # --no-build-isolation so its build actually uses those instead of a
    # fresh isolated env. (Only pandas needs this — the isolation flag
    # only matters for packages built from source; other requirements
    # install prebuilt wheels normally either way.)
    #
    # Round 2 (2026-09-30): with build isolation off, pip no longer
    # auto-fetches pandas 1.5.3's OTHER declared build-time requirement
    # either — Cython (needed to compile its .pyx sources) — so that has
    # to be pre-installed too, same reasoning as numpy above. Pinned
    # <3 because pandas 1.5.3 predates Cython 3's breaking changes.
    run([VENV_PYTHON, "-m", "pip", "install", "-q", "setuptools<81", "wheel"])
    run([VENV_PYTHON, "-m", "pip", "install", "-q", "numpy<2.0", "Cython<3"])
    try:
        run([VENV_PYTHON, "-m", "pip", "install", "-q",
             "--no-build-isolation", "pandas<2.0"])
    except subprocess.CalledProcessError:
        # Confirmed on a real Windows run, 2026-09-30: "Microsoft Visual
        # C++ 14.0 or greater is required" — Windows Python 3.12+ needs
        # an actual C/C++ compiler to build pandas from source, which
        # the setuptools/Cython fixes above can't substitute for and
        # most computers don't have. No fix for this in-place — the
        # real fix is a different Python. Tell the user exactly what to
        # do instead of just letting the raw traceback print. (The venv
        # gets cleaned up automatically by __main__'s wrapper below, so
        # this message doesn't need to mention deleting it manually.)
        if IS_WINDOWS:
            print("\n" + "=" * 66)
            print("pandas couldn't be built from source. On Windows, Python")
            print("3.12+ needs Microsoft C++ Build Tools to do this — most")
            print("computers don't have it installed.")
            print()
            print("Easiest fix: install Python 3.11 instead (pandas has a")
            print("ready-made package for it, nothing to compile):")
            print("    winget install -e --id Python.Python.3.11")
            print("then re-run setup using it specifically:")
            print("    py -3.11 script\\setup.py")
            print("=" * 66)
        raise
    run([VENV_PYTHON, "-m", "pip", "install", "-q", "-r", req_file])


def _download(url, dest, retries=3):
    """urlretrieve with retry + cleanup — a dropped connection otherwise
    leaves a truncated file behind that a bare os.path.exists() check
    would mistake for a completed download on the next run."""
    for attempt in range(1, retries + 1):
        try:
            urllib.request.urlretrieve(url, dest)
            return
        except (urllib.error.URLError, OSError) as e:
            if os.path.exists(dest):
                os.remove(dest)
            if attempt == retries:
                raise
            print(f"    Download failed ({e}), retrying "
                  f"({attempt}/{retries})...")


def _needs_download(dest, expected_size):
    if not os.path.exists(dest):
        return True
    if os.path.getsize(dest) != expected_size:
        print(f"    {os.path.relpath(dest, WORKSHOP_DIR)} exists but is "
              "the wrong size (incomplete/corrupt download) — "
              "re-downloading.")
        os.remove(dest)
        return True
    return False


def download_toy_data():
    step("Downloading toy data (weight models) from Zenodo")
    for filename, dest_rel, expected_size in DATA_FILES:
        dest = os.path.join(WORKSHOP_DIR, dest_rel)
        if not _needs_download(dest, expected_size):
            print(f"    {dest_rel} already exists, skipping.")
            continue
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        url = f"{ZENODO_BASE}/{filename}/content"
        print(f"    Downloading {filename} -> {dest_rel}")
        _download(url, dest)

    tissue_file = os.path.join(WORKSHOP_DIR, "tissue.txt")
    if not os.path.exists(tissue_file):
        print("    Writing tissue.txt")
        with open(tissue_file, "w") as f:
            f.write(TISSUE_FILE_CONTENT)

    celltype_file = os.path.join(WORKSHOP_DIR, "celltype.txt")
    if not os.path.exists(celltype_file):
        print("    Writing celltype.txt")
        with open(celltype_file, "w") as f:
            f.write(CELLTYPE_FILE_CONTENT)

    gwas_file = os.path.join(WORKSHOP_DIR, GWAS_FILE_REL)
    if _needs_download(gwas_file, GWAS_FILE_SIZE):
        os.makedirs(os.path.dirname(gwas_file), exist_ok=True)
        url = f"{GWAS_ZENODO_BASE}/{GWAS_FILENAME}/content"
        print(f"    Downloading {GWAS_FILENAME} -> {GWAS_FILE_REL}")
        _download(url, gwas_file)


def run_check():
    step("Verifying everything is ready")
    check_script = os.path.join(WORKSHOP_DIR, "script", "00_check_setup.py")
    subprocess.run([VENV_PYTHON, check_script], check=False)


if __name__ == "__main__":
    print("TWAS Workshop setup — this will take a few minutes the first time.")
    check_python_version()
    create_venv()
    # If package installation fails partway through, the venv is left in
    # a half-set-up state — create_venv() would then skip recreating it
    # on the next run (since VENV_PYTHON already exists), silently
    # reusing something broken. Eric, 2026-09-30: remove it automatically
    # on failure instead of requiring a manual delete before re-running.
    try:
        install_requirements()
    except subprocess.CalledProcessError:
        remove_venv("setup failed partway through — starting clean next time")
        sys.exit(1)
    download_toy_data()
    run_check()
    print("\nSetup finished. Next: run the workshop script —")
    if IS_WINDOWS:
        print(r"    venv\Scripts\python.exe script\run_native.py")
    else:
        print("    bash script/run_native.sh")
    print("(see docs/native_setup_guide.md if anything above said MISSING)")
