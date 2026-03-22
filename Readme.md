# fastjsonl

Ultra-fast streaming JSON Lines (JSONL/NDJSON) for Python, 

[![PyPI](https://img.shields.io/pypi/v/fastjsonl?color=blue)](https://pypi.org/project/fastjsonl/)  
[![Python](https://img.shields.io/pypi/pyversions/fastjsonl)](https://pypi.org/project/fastjsonl/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  
[![Tests](https://img.shields.io/github/actions/workflow/status/Web4application/fastjsonl/ci.yml?branch=main)](https://github.com/Web4application/fastjsonl/actions)

### Features
- Blazing-fast via orjson
- Streaming read/write (low memory)
- Built-in compression: gzip, bzip2, xz, zstd
- Batched I/O + orjson options support

### Installation

```bash
pip install fastjsonl
# For zstd:
pip install "fastjsonl[zstd]"
```
## Features

- Extremely fast parsing and serialization via **orjson**
- Streaming read/write — process gigabyte-scale JSONL files with low memory footprint
- Built-in compression support:  
  - gzip (`.gz`)  
  - bzip2 (`.bz2`)  
  - xz/lzma (`.xz`, `.lzma`)  
  - zstd (`.zst`) — best speed/compression ratio (requires `zstandard` extra)
- Batched I/O to minimize overhead on large writes
- Pass any `orjson` option flags (e.g. pretty-print, sort keys, numpy/UUID/dataclass support)
- Simple functional API: `load()` and `dump()`

## Installation

```sh
pip install fastjsonl
```
## installation
```sh
pip install fastjsonl
# For zstd support:
pip install fastjsonl[zstd]
```
## BASH
```sh
├── src/                    # Source code (src layout prevents accidental imports during dev)
│   └── fastjsonl/
│       ├── __init__.py
│       ├── __version__.py   # Single source of truth: __version__ = "0.1.0"
│       └── core.py          # Your FastJSONL class + load/dump functions
├── tests/                   # pytest suite
│   ├── test_load.py
│   └── test_dump.py
├── benchmarks/              # asv or simple scripts comparing to orjsonl, jsonlines, manual orjson
├── .github/
│   └── workflows/
│       ├── ci.yml           # Tests + lint on push/PR
│       └── release.yml      # Build & publish on tags
├── pyproject.toml           # All config: metadata, build-system, deps, tools
├── README.md                # Detailed usage, benchmarks, install, why faster
├── LICENSE                  # MIT (common for perf libs) or Apache-2.0
├── CHANGELOG.md             # KeepVersion-style or conventional commits
├── .gitignore               # Standard Python + Rust/C extensions if any
└── MANIFEST.in              # If needed for non-Python files (rare with pyproject.toml)

```
```bash
fastjsonl/
├── src/
│   └── fastjsonl/
│       ├── __init__.py
│       ├── __version__.py     # __version__ = "0.1.0"
│       └── fastjsonl.py       # Paste/improve our FastJSONL class from earlier
├── tests/
│   ├── __init__.py
│   ├── test_load.py
│   └── test_dump.py           # Add simple pytest cases
├── benchmarks/
│   └── bench.py               # Optional: pytest-benchmark or simple timing script
├── .github/workflows/
│   ├── ci.yml                 # Tests/lint
│   └── publish.yml            # Release on tags
├── pyproject.toml             # See below
├── README.md
├── LICENSE                    # MIT
├── CHANGELOG.md               # Start with v0.1.0 initial release
└── requirements-dev.txt       # For local dev: pytest, ruff, etc.
```
# Quick test
```python
from fastjsonl import load, dump
import orjson

# Read compressed streaming (auto-detects .gz/.zst/etc.)
for record in load("huge_logs.jsonl.zst"):
    print(record["timestamp"], record["level"])

# Write with zstd level 5 (good speed/ratio balance)
data = [{"id": i, "value": f"test_{i}"} for i in range(100_000)]
dump(data, "output.jsonl.zst", compression="zstd", level=5, option=orjson.OPT_INDENT_2)
```

# an “APL-flavored” ultra-fast JSONL processor
```python
from fastjsonl import load_apl  # hypothetical APL-inspired mode

data = load_apl("huge.jsonl.zst")   # returns an "APL-like array" proxy (lazy, chunked)
timestamps = data['timestamp']       # array select — no loop
high_values = data[data['value'] > 1000]  # vectorized filter
avg = (+/data['value']) / ⍴data      # sum / shape — APL-style reduction
