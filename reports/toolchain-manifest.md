# Verified Toolchain Manifest — MONSTER-BRIDGE

Every entry below was executed on this machine during the build
(2026-10-31 / 2026-11-01). "Verified" means the tool ran and produced the
recorded result; it does not mean the tool is equivalent to any other tool.

## Verified by execution

| Tool | Version (as printed by the tool) | Location | Evidence |
|---|---|---|---|
| Lean 4 (project toolchain) | leanprover/lean4 v4.9.0 | elan (~/.elan) | lean/ lake build log, proofs/lean-build-log.txt |
| Lean 4 (system default) | 4.12.0 | elan | `monster doctor` output, reports/phase8-rust.md |
| Mathlib | v4.9.0 (cache: 4,732 files unpacked) | lean/.lake/packages | proofs/lean-build-log.txt |
| Rust / Cargo | rustc 1.99.0, cargo 1.99.0 | system PATH | cargo test 14/14, reports/phase8-rust.md |
| GCC | 13.3.0 | system PATH | `monster doctor` |
| Java | Temurin 21.0.12.1 | ~/workspace/.tools/jdk-21.0.12.1+1 | Alloy driver runs |
| Alloy | 6 (jar build 2025-01-09) | ~/workspace/hcalc-counter/alloy.jar | alloy/results.txt (41 commands) |
| Uiua | 0.19.1 | ~/workspace/.tools/uiua/uiua | uiua/outputs/, 17/17 cross-checks |
| Mathics3 | 10.0.1 (CPython 3.12.3, SymPy 1.14.0, mpmath 1.3.0, numpy 2.5.4) | ~/workspace/.tools/mathics-venv/bin/mathics | wolfram/outputs/version.txt |
| SWI-Prolog | 9.0.4 (x86_64-linux) | /usr/bin/swipl (dpkg) | reports/toolchain-curry.md |
| PAKCS (Curry) | 3.9.0 of 2025-10-29 (swi 9.0 backend) | ~/workspace/.tools/pakcs-3.9.0 | reports/toolchain-curry.md (§3 battery 7/7) |
| HiGHS | 1.15.1 (githash 04024d7) | ~/workspace/.tools/highs/bin/highs | reports/toolchain-highs.md |
| Python | 3.12.3 | system | seed + checkers runtime |
| GNU time | 1.9 | /usr/bin/time (dpkg) | benchmarks/corpus-benchmark.txt |

Install provenance and hashes: reports/toolchain-curry.md (SWI/PAKCS,
incl. tarball SHA-256 6d0eb1e2… and the .deb sets saved under
~/workspace/.tools/debs/), reports/toolchain-highs.md (release tarball
SHA-256 5b05b157…, matching the publisher's digest). Reinstall after a VM
replacement: scripts/reinstall-swi.sh plus the saved tarballs/debs under
~/workspace/.tools.

## Not installed / not operational — stated plainly

- **Mathematica / Wolfram Engine**: not installed (commercial). Mathics3
  is used instead and is NOT equivalent to Mathematica; its capability
  failures are enumerated in wolfram/outputs/capabilities.out (BitAnd,
  TestReport, VerificationTest return unevaluated).
- **AMPL**: not installed. Files under ampl/ with .mod extension are
  AMPL-format artifacts; none has been executed by an AMPL runtime.
  Optimization execution is by HiGHS only.
- **CBC, GLPK**: not installed. HiGHS is the only solver present.
- **xmllint**: not installed; XSD well-formedness is checked with
  Python's xml.etree (schemas/test-output.txt says so).
