# HiGHS toolchain — install and verification

Status: **VERIFIED**

## Install

- Install location: `~/workspace/.tools/highs/` with the runnable
  binary at `~/workspace/.tools/highs/bin/highs`
- Install route: official prebuilt release binary (not a source build)
- Source URL: https://github.com/ERGO-Code/HiGHS/releases/download/v1.15.1/highs-1.15.1-x86_64-linux-gnu-static-mit.tar.gz
- Release: HiGHS v1.15.1, from https://github.com/ERGO-Code/HiGHS/releases
  (release tag `v1.15.1`, asset
  `highs-1.15.1-x86_64-linux-gnu-static-mit.tar.gz`)
- Downloaded archive SHA-256 (computed locally with `sha256sum`):
  `5b05b157e512390b6bcc14517f2c68736b89aae286ab89fd0666c3c80a1569bc`
  This matches the digest published for that asset in the GitHub
  releases API response for v1.15.1.
- Extraction: `tar --no-same-owner -xzf` into
  `~/workspace/.tools/highs/` (the archive contains `bin/`, `lib/`,
  `include/`, `share/` at its top level).
- Version, from an actual run of `~/workspace/.tools/highs/bin/highs --version`:

  ```
  HiGHS version 1.15.1 Githash 04024d7. Copyright (c) 2026 under MIT licence terms
  ```

## Verification model

File executed: `ampl/verification/workload.lp` (LP format).
The same model is also written in `ampl/verification/workload.mps`
(MPS format), in `ampl/verification/README.md` (description and hand
enumeration), and in AMPL syntax in `ampl/workload.mod`.

Model — verification-workload allocation:

| Task | Hour cost | Coverage value |
|------|-----------|----------------|
| t1   | 3         | 10             |
| t2   | 2         | 9              |
| t3   | 4         | 13             |
| t4   | 3         | 8              |

- Binary variables: `t1, t2, t3, t4` (1 = task selected)
- Objective: maximise `10 t1 + 9 t2 + 13 t3 + 8 t4`
- Budget constraint: `3 t1 + 2 t2 + 4 t3 + 3 t4 <= 8`
- Linking constraint: `t2 - t1 <= 0` (t2 requires t1)

Hand computation: explicit enumeration of every feasible subset is
tabulated in `ampl/verification/README.md`. The feasible subset with
the highest coverage is {t1, t2, t4}: cost `3 + 2 + 3 = 8`, coverage
`10 + 9 + 8 = 27`. The next-best feasible subset is {t1, t3} with
coverage 23, so the optimum is unique.

**Hand-computed optimum: 27, at t1 = 1, t2 = 1, t3 = 0, t4 = 1.**

## Solver run

Command run (from `~/workspace/monster-engine`):

```
~/workspace/.tools/highs/bin/highs ampl/verification/workload.lp --solution_file ampl/verification/highs-solution.txt
```

- Full solver output: `ampl/verification/highs-run.txt`
- Solution file: `ampl/verification/highs-solution.txt`
- Solver output states, in its Solving report:

  ```
    Status            Optimal
    Primal bound      27
    Dual bound        27
  ```
  and `27 (objective)` under Solution status.
- Solution file states `Model status` / `Optimal`, `Objective 27`,
  and the variable values `t1 1`, `t2 1`, `t3 0`, `t4 1`
  (row values: `budget 8`, `link 0`).

Programmatic verification (grep over the saved output):

- `grep "Status            Optimal" ampl/verification/highs-run.txt` — matched (line 40)
- `grep "Primal bound      27" ampl/verification/highs-run.txt` — matched (line 41)
- `grep "^Objective 27" ampl/verification/highs-solution.txt` — matched

The MPS file was also run with the same binary as a cross-check; it
likewise reported Status Optimal with primal bound 27.

## Comparison

- Hand-computed optimum: **27**
- Solver objective: **27**
- Solver status: **Optimal**
- Solver solution: t1 = 1, t2 = 1, t3 = 0, t4 = 1 — the hand-computed
  unique optimum.

Hand optimum and solver objective match, so the status is VERIFIED.

## AMPL note

`ampl/workload.mod` is the same model written in AMPL syntax, as a
separate artifact. Its header states that it is AMPL-format, that
AMPL is not installed, and that it has not been executed by an AMPL
runtime. No AMPL execution is claimed anywhere in this report or in
the model files; the only solver executed was HiGHS, on the LP (and,
as a cross-check, MPS) file.
