# Phase 8 — Rust orchestration CLI

Status of the `monster` binary (`rust/`, cargo project, std-only, no
external crates), as run on this machine on 2026-10-31.

## Build

- `cargo build` — succeeds (debug profile; binary at
  `rust/target/debug/monster`).
- `cargo test` — 14 passed, 0 failed. Coverage: SHA-256 standard
  vectors (empty, `abc`, 56-byte multi-block), pattern matcher
  (`.`-wildcard hits `j invariant` / `J-Invariant` / `vertex operator`,
  substring hit `modularity`, clean-line misses, wildcard-is-not-optional
  misses), JSON escaping and strict parsing, XML escaping, 3-cycle
  detection, DAG topological sort, contract kind counting, validator
  accept and unsubstantiated-verified reject.

## Differential test — `scripts/difftest.sh`

Result as run: **DIFFTEST PASS** (8/8 checks).

- Samples scan: Rust and bridge.py outputs match record-for-record
  (4 records), and the Rust output reproduces the shipped
  `monster_bridge/samples/hits.jsonl` exactly, all fields including
  `path` (same scan root, so no path normalization was needed).
- Generated tricky tree (wildcard variants, upper-case extension,
  excluded `.md` file, empty file, nested directories, and the
  `a/inner.txt` vs `a-b.txt` ordering case where pathlib component
  order differs from plain string order): 17 records, record-for-record
  identical; a follow-up byte-level `diff` of the two JSONL files on
  the ordering-trap tree was also clean.
- XML: claim counts match (17); bridge.py validates the Rust-produced
  XML and `monster verify` accepts the Python-produced XML.

## Command runs observed

- `scan` on the seed: 4 records; `--max-hits 2` caps at exactly 2.
- `classify` on the seed: `{moonshine: 2, monster: 1, lie: 1}`,
  total 4 — matches scan's assignment.
- `evaluate` on the seed: 4 records, 1 source, 1 distinct file.
- `resolve`: dependency DAG orders `c1, c2, c3` with per-claim
  derivation entries; a self-dependency is reported as
  `dependency cycle detected` with exit 1; an unresolved ref is
  rejected with `missing dependency: <claim>` and exit 1.
- `verify`: accepts the seed XML (`{"valid": true, "claims": 4}`);
  rejects an unsubstantiated `verified` claim with the same message
  bridge.py produces, exit 1 on both implementations.
- `contract`: `contracts/families.json` was absent when this phase
  started and was authored by a parallel worker during the run; the
  real file parses and reports MON 9, MOON 6, LIE 7, GEO 6 items by
  kind. A fixture run (`rust/tests/families.fixture.json`) and a
  malformed-input run (exit 1) were also performed.
- `counterexample`: with no `alloy/results.txt` present, prints
  `UNSUPPORTED` with the reason and exit 1; against a recorded results
  file it prints the recorded line with status `BOUNDED`, exit 0, and
  `UNSUPPORTED` for an unrecorded module. No solver run is attempted.
- `report` over the engine tree: lists the report and benchmark
  artifacts present with SHA-256 and `alloy/results.txt` as absent.
- `doctor`: probes returned available with versions for lean 4.12.0,
  lake, cargo 1.99.0, rustc 1.99.0, gcc 13.3.0, java 21, uiua 0.19.1,
  HiGHS 1.15.1, and PAKCS 3.9.0; the Alloy jar is present; mathics is
  present with no version string captured. Entries reflect the actual
  probe results on this machine.

## Notes

- No git commands were run; `monster_bridge/` was read, not modified.
- The JSON/XML parsers are hand-rolled for the engine's fixed formats
  and are strict; scope is documented in `rust/README.md`.
- Determinism: sorted iteration everywhere (pathlib-component file
  order for scan, BTreeMap ordering for counts, document-order
  tie-breaking for topological sorts).
