# monster — Rust orchestration CLI

A standard-library-only Rust binary that drives the MONSTER-BRIDGE engine.
Its scan / normalize / verify behavior is semantically identical to
`monster_bridge/src/bridge.py` (same record fields, same domain families,
same validation rules and error messages), verified record-for-record by
`scripts/difftest.sh` at the repository root.

Build: `cargo build` (debug) or `cargo build --release`. The binary is
named `monster`. Every command prints exactly one JSON object to stdout
and never executes extracted text.

## Exit codes

- `0` — success
- `1` — validation / logic failure (invalid claims, dependency cycle,
  unresolved reference, malformed input content, no recorded result)
- `2` — usage / IO error (bad arguments, unreadable or unwritable files)

Failures print a JSON object with an `error` field (verify prints
`{"valid": false, "error": ...}`).

## Parser scope

The hand-rolled JSON and XML parsers target the engine's own fixed
formats — the flat record objects of the JSONL corpus files, the
`contracts/families.json` document, and research v1 XML — not general
JSON or XML. They are strict: malformed input, duplicate XML attributes,
mismatched tags, unknown entities, and trailing data are rejected with
errors rather than repaired.

## Commands

- `monster scan <root> <out.jsonl> [--max-hits N]` — streaming line scan
  with bridge.py semantics: extensions `.txt .tex .wl .m .lean .als
  .curry` (case-insensitive), files in pathlib component order, source
  ids `s1...` by that order, one `candidate` record per (line, domain)
  hit with the line text, 1-based line number, and the file's SHA-256.
  The bridge.py regex families (moonshine / monster / lie) are matched
  as case-insensitive alternatives where `.` is the regex any-character
  wildcard, so `j.invariant` also matches `j invariant` and
  `J-Invariant`. SHA-256 is implemented in-crate and unit-tested against
  the standard vectors.
- `monster normalize <in.jsonl> <out.xml>` — bridge.py `export()`:
  research v1 XML, sources in first-appearance order, a source-collision
  error when one source id maps to two different (path, sha256) pairs,
  claims in file order with status `candidate` and the fixed assumptions
  text.
- `monster classify <in.jsonl>` — re-derives domains from each scanned
  line with the same matcher (records sharing one source/path/line are
  one line with several hits, exactly as scan assigns them) and prints
  per-domain counts plus the total.
- `monster resolve <claims.xml>` — builds the dependency graph from
  `dependency` elements, rejects unresolved refs, reports dependency
  cycles as an error object with exit 1, and otherwise prints a
  topological order with, per claim, its derivation entry:
  `{"claim": ..., "clause": "dependency", "dependencies": [...]}`.
- `monster contract <families.json>` — per-family item counts by `kind`
  as JSON. Accepts a top-level object (optionally under a `families`
  key) of arrays, or of objects holding an `items` / `members` /
  `contracts` array, or an array of named family entries. Malformed
  input exits 1.
- `monster counterexample <module.als>` — reports only recorded Alloy
  results: if `alloy/results.txt` (cwd, parent, or the engine tree)
  contains a line naming the module, that line is printed with status
  `BOUNDED`; otherwise status `UNSUPPORTED` with a reason and exit 1.
  No solver run is attempted or implied.
- `monster verify <claims.xml>` — bridge.py `validate()`: root/version
  check, unique claim ids, source resolution, status vocabulary
  `{candidate, rejected, bounded, verified}`, non-empty
  expression/assumptions, dependency resolution, and verified claims
  requiring formal-proof evidence (tool in `{lean, coq, agda,
  isabelle}`, status `verified`, 64-hex `artifact_sha256`). Prints
  `{"valid": bool, "claims": N}` or the specific error.
- `monster evaluate <in.jsonl>` — summary statistics: record count,
  per-domain counts, per-source counts, distinct file count.
- `monster report <dir>` — aggregates `reports/*.md`,
  `alloy/results.txt`, and `benchmarks/*.txt` under `<dir>` into one
  JSON summary listing each artifact with its SHA-256; missing
  artifacts are listed with `present: false` (not an error).
- `monster doctor` — toolchain manifest: probes `lean`, `lake`,
  `cargo`, `rustc`, `gcc`, `java`, the Alloy jar's presence, `uiua`,
  `mathics`, `highs`, and `pakcs` (PATH, `~/.elan/bin`, the workspace
  `.tools` tree, and the workspace JDK as applicable), spawning
  `--version`/`-version` probes with a 3-second timeout and reporting
  `{"available": bool, "version": string-or-null}` per tool.

## Verified vs limited accounting

- Verified against bridge.py by `scripts/difftest.sh`: scan (samples
  and a generated tricky tree, byte-identical JSONL including the
  shipped `samples/hits.jsonl`), normalize claim counts, and both
  validators cross-accepting each other's XML.
- Verified by cargo unit tests (14): SHA-256 vectors, pattern matcher
  including `.`-wildcard and substring cases, JSON escaping and parsing,
  XML escaping, 3-cycle detection, DAG topological sort, contract
  counting, and validator accept/reject cases.
- Verified by direct runs: resolve (order, cycle, unresolved ref),
  verify accept/reject, evaluate, classify on the seed,
  contract on the engine's `contracts/families.json` and on a malformed
  document, counterexample BOUNDED/UNSUPPORTED paths against a recorded
  results file, report over the engine tree, doctor on this machine.
- Limited by design: `counterexample` never runs Alloy — it only reads
  recorded results. `doctor` reports what the probes actually return
  on the machine it runs on. The `contract` shape tolerance is limited
  to the documented shapes; anything else is malformed input (exit 1).
