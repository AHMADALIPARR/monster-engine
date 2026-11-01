# wolfram/ — Mathics3 / Wolfram subsystem

This directory contains the Wolfram-language subsystem of MONSTER-BRIDGE. It runs under Mathics3, an open-source Wolfram Language interpreter, and provides symbolic normalisation and exact arithmetic checks around published J-function data.

**Disclaimer: Mathics3 is not Mathematica, and no Mathematica-only feature is claimed, relied on, or implied by this subsystem.** Operations that Mathics3 does not evaluate produce an explicit `CAPABILITY_FAILURE: <op>` line and, for required operations, a nonzero exit — never a silent substitution and never an unevaluated expression presented as a result.

## Tool

- Mathics3 10.0.1, at `~/workspace/.tools/mathics-venv/bin/mathics`, always invoked as `mathics -f file.wl`.
- Version string as printed by the tool (saved in `outputs/version.txt`):

  ```
  Mathics3 10.0.1
  Running on linux CPython 3.12.3 (main, Aug 31 2026, 10:18:26) [GCC 13.3.0]
  using SymPy 1.14.0, mpmath 1.3.0, numpy 2.5.4, cython Not installed, scipy 1.18.1, skimage Not installed
  ```

## Files

- `normalize.wl` — defines the J-function coefficient list as published data (`{744, 196884, 21493760, 864299970}`, the constant term and the `q`, `q^2`, `q^3` coefficients of `j(τ) = q^-1 + 744 + 196884 q + 21493760 q^2 + 864299970 q^3 + …`), expands/factors two polynomial identities, verifies McKay arithmetic, and prints exact rational ratios and integer differences of the coefficients.
- `capabilities.wl` — probes a fixed list of operations on tiny inputs with explicit evaluated/unevaluated checks, printing `SUPPORTED` (with the evaluated result) or `CAPABILITY_FAILURE` (with the reason) for each.
- `run.sh` — runs both scripts, captures output to `outputs/`, and exits nonzero if either script exits nonzero or if any expected `True` line is absent from `normalize.wl` output.
- `outputs/normalize.out`, `outputs/capabilities.out`, `outputs/version.txt` — captured output of the most recent `run.sh` run.

## Running

```sh
sh wolfram/run.sh
```

## Capability summary (from the captured run)

Required operations — `Expand`, `Factor`, `Coefficient`, `Part` — are `SUPPORTED`. `Factor` is a required operation in this subsystem because it evaluates in Mathics3 10.0.1 (`Factor[x^2 - 1]` gives `(-1 + x) (1 + x)`); it is not demoted to optional.

Optional operations `Simplify` and `Series` are also `SUPPORTED` in the captured run. Optional operations `BitAnd`, `TestReport`, and `VerificationTest` are `CAPABILITY_FAILURE` in the captured run — they return unevaluated. The full per-operation list with exact results is in `outputs/capabilities.out` and in `reports/phase-wolfram.md`.
