# Phase 3 — Corpus extraction report

Directive section 5 (corpus extraction) and section 15 Phase 3. The
owner's seed under `monster_bridge/` was not edited; the extractor is a
separate component under `corpus/`.

## What was built

- `corpus/extract.py` — streaming, non-evaluating extractor.
  - Semantically consistent with the seed's `scan()`: same record fields
    in the same order (`id`, `source`, `path`, `sha256`, `line`,
    `domain`, `expression`, `status`), same extension set
    {.txt, .tex, .wl, .m, .lean, .als, .curry}, same sorted traversal
    with per-file source ids `s1`, `s2`, ..., same per-file SHA-256 over
    raw bytes, same one-record-per-(line, domain) granularity, every
    record `candidate`, same default `--max-hits` cap of 1000000.
  - The seed's three domain regexes (moonshine, monster, lie) are kept
    verbatim, branch by branch: each seed alternation branch is a
    numbered sub-pattern of its family, so family-level matching is
    identical to the seed's combined regex.
  - Two contract families added (directive section 6): `geometry`
    (recursive subdivision, tensor, equivariance, equivariant,
    coordinate transformation) and `modular` (modular form,
    q-expansion, McKay-Thompson, hauptmodul). Overlaps behave as in the
    seed: one record per (line, family), so e.g. a "modular form" line
    yields both a moonshine record (via `modular`) and a modular record,
    and a "hauptmodul" line yields moonshine and modular records.
  - Each record adds three fields after the seed fields: `rule`
    (`"<family>:<index>"`, the 0-based index of the first matching
    sub-pattern in the family's list; the full index map is in the
    extractor's docstring), `offset` (byte offset of the line start in
    its file), and `encoding` (the constant string `"utf-8"`; files are
    decoded as UTF-8 with replacement of undecodable bytes).
  - Streaming: files are read one line at a time in binary mode and each
    line decoded individually, records are written as found, and the
    only accumulated state is a counter. Neither a whole file nor the
    hit set is held in memory, and file contents are never evaluated.
  - Seed-consistency check (actually run): the seed scanner and this
    extractor were both run over `monster_bridge/samples/`. The seed
    produced 4 records; this extractor produced the same 4 records, with
    every seed field equal, in the same order, plus the three new
    fields.
- `corpus/gen_synthetic.py` — deterministic synthetic corpus generator
  (seeded PRNG, fixed seed 20261031 recorded in the source). It writes
  7 files of 150,000 lines (1,050,000 lines total, one file per
  supported extension) under `corpus/synthetic/`, each file headed by a
  SYNTHETIC TEST DATA line, with exactly one planted hit line every 50
  lines and neutral filler elsewhere. It prints the exact expected
  record count per family, computed from its planted-template
  annotations, and also writes them to
  `corpus/synthetic/expected-hits.json`. Before generation, every
  planted and filler template was checked against the extractor's
  pattern families and matched its annotation exactly.
- `corpus/samples/established-facts.txt` — four lines of established
  published mathematics, each labeled inline as a published fact: the
  J-function q-expansion coefficients (1/q + 744 + 196884q + 21493760q²
  + 864299970q³ + …), McKay's observation 196884 = 196883 + 1, the
  Monster group order 808017424794512875886459904961710757005754368000000000,
  and the definition of a McKay-Thompson series. No citations are
  attached; the lines refer to these as established published values.
  Running the extractor over `corpus/samples/` produced 6 records,
  saved at `corpus/samples/established-facts.hits.jsonl` (modular:1 on
  the q-expansion line, monster:3 and monster:0 on the representation
  and group-order lines, and moonshine:0 / monster:0 / modular:2 on the
  McKay-Thompson line).

## Benchmark (synthetic corpus only)

Measured by running the extractor over `corpus/synthetic/` under
`/usr/bin/time -v` (GNU time 1.9; the VM image did not ship
`/usr/bin/time`, so the Debian `time` package was installed before the
run). Raw output: `benchmarks/corpus-benchmark.txt`. Summary:
`benchmarks/corpus-benchmark.md`.

- Total lines: 1,050,000; total bytes: 69,623,312
- Wall time: 38.97 s; throughput: 26,943.8 lines/sec
- Peak RSS: 19,212 kbytes
- Machine context: nproc 4, Python 3.12.3; the timed job received 45%
  of a CPU (shared VM), so wall-clock throughput is contention-limited;
  user time was 17.71 s.
- The corpus is synthetic test data. These numbers measure this
  extractor on generated data and say nothing about historical
  documents.

## Recall check

Extracted record counts per family, counted by streaming the benchmark
hits file, against the generator's planted counts:

| Family | Expected | Extracted | Result |
|---|---|---|---|
| moonshine | 6,043 | 6,043 | MATCH |
| monster | 5,010 | 5,010 | MATCH |
| lie | 4,012 | 4,012 | MATCH |
| geometry | 4,895 | 4,895 | MATCH |
| modular | 4,056 | 4,056 | MATCH |
| total | 24,016 | 24,016 | MATCH |

Result: PASS — exact match on every family; no mismatch had to be
investigated. An internal optimization during the work (a combined
per-family alternation used for hit detection, with the per-branch scan
kept for rule identification on hit lines) was verified to produce
byte-identical output to the unoptimized extractor over the full
synthetic corpus before the benchmark of record was run.
