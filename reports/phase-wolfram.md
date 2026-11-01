# Phase report — Wolfram / Mathics3 subsystem (wolfram/)

## Standing disclaimer

Mathics3 is not Mathematica, and no Mathematica-only feature is claimed, relied on, or implied by this subsystem. Every result below was produced by Mathics3 and is traced to a line in the saved outputs under `wolfram/outputs/`. An operation that returns unevaluated is recorded as a `CAPABILITY_FAILURE`, never as a computed result.

## What ran

- Command: `sh wolfram/run.sh`, which invokes the tool as `mathics -f file.wl` for each script (bare invocation is not used).
- Scripts: `wolfram/normalize.wl` and `wolfram/capabilities.wl`.
- Captured outputs: `wolfram/outputs/normalize.out`, `wolfram/outputs/capabilities.out`, `wolfram/outputs/version.txt`.
- Result of the run: `run.sh` exit status 0, with its final line `run.sh: PASS - both scripts ran and all expected True lines are present.` Both scripts individually exited 0 (`normalize.wl exit status: 0`, `capabilities.wl exit status: 0` in the `run.sh` output).

## Tool version

Version string as printed by the tool, verbatim from `wolfram/outputs/version.txt`:

```
Mathics3 10.0.1
Running on linux CPython 3.12.3 (main, Aug 31 2026, 10:18:26) [GCC 13.3.0]
using SymPy 1.14.0, mpmath 1.3.0, numpy 2.5.4, cython Not installed, scipy 1.18.1, skimage Not installed
```

Tool path: `~/workspace/.tools/mathics-venv/bin/mathics`.

## normalize.wl — results traced to outputs/normalize.out

Published data (labelled as published data in the script comments; reproduced as data, not derived):

- `J coefficients (published data): jCoeffs = {744, 196884, 21493760, 864299970}`
- These are the constant term and the coefficients of `q`, `q^2`, `q^3` in `j(τ) = q^-1 + 744 + 196884 q + 21493760 q^2 + 864299970 q^3 + …`.

Polynomial identities (original and normalised forms both printed in the output):

- Original 1: `(x + y) ^ 2` — Normalised 1: `Normalized 1 (Expand[(x + y)^2]): x ^ 2 + 2 x y + y ^ 2` — `Identity check 1: Expand[(x + y)^2] == x^2 + 2 x y + y^2 : True`
- Original 2: `-1 + x ^ 2` — Normalised 2: `Normalized 2 (Factor[x^2 - 1]): (-1 + x) (1 + x)` — `Identity check 2: Factor[x^2 - 1] == (x - 1) (x + 1) : True`
- Cross-check: `Normalized 2b (Expand[(x - 1) (x + 1)]): -1 + x ^ 2` — `Identity check 2b: Expand[(x - 1) (x + 1)] == x^2 - 1 : True`

Both `Factor` and `Expand` evaluate in this Mathics3 build, so both are used; neither required the capability-failure path in this run.

Coefficient extraction:

- `Coefficient[jPoly, q, 1] = 196884` — `Coefficient check: Coefficient[jPoly, q, 1] == 196884 : True`
- `Coefficient[jPoly, q, 0] = 744`, `Coefficient[jPoly, q, 2] = 21493760`, `Coefficient[jPoly, q, 3] = 864299970`

McKay arithmetic:

- `McKay difference: 196884 - 196883 = 1`
- `McKay verification: 196884 - 196883 == 1 : True`
- `McKay form: 196884 = 196883 + 1 : True`

Exact rational ratios (no floating-point values are printed):

- `Ratio c1/c0: 196884/744 = 16407 / 62`
- `Ratio c2/c1: 21493760/196884 = 5373440 / 49221`
- `Ratio c3/c2: 864299970/21493760 = 86429997 / 2149376`
- `Ratio c1/196883: 196884/196883 = 196884 / 196883`

Exact integer differences:

- `Difference c1 - c0: 196884 - 744 = 196140`
- `Difference c2 - c1: 21493760 - 196884 = 21296876`
- `Difference c3 - c2: 864299970 - 21493760 = 842806210`

## capabilities.wl — SUPPORTED vs CAPABILITY_FAILURE, exact list from outputs/capabilities.out

Required operations (a failure of any one exits nonzero):

- SUPPORTED: Expand — `SUPPORTED: Expand result = x ^ 2 + 2 x y + y ^ 2`
- SUPPORTED: Factor — `SUPPORTED: Factor result = (-1 + x) (1 + x)`
- SUPPORTED: Coefficient — `SUPPORTED: Coefficient result = 196884`
- SUPPORTED: Part — `SUPPORTED: Part result = 196884`

Factor status note: Factor is required, not demoted to optional, because it evaluates in the actual run above. The demotion clause in the assignment therefore does not apply.

Optional operations:

- SUPPORTED: Simplify — `SUPPORTED: Simplify result = 1 + x`
- SUPPORTED: Series — `SUPPORTED: Series result = 1 + x + x ^ 2 / 2 + x ^ 3 / 6 + O[x] ^ 4`
- CAPABILITY_FAILURE: BitAnd — `CAPABILITY_FAILURE: BitAnd unevaluated on BitAnd[5, 3], expected 1 - Bit* builtins are not evaluated by Mathics3`
- CAPABILITY_FAILURE: TestReport — `CAPABILITY_FAILURE: TestReport unevaluated - TestReport is not implemented in Mathics3`
- CAPABILITY_FAILURE: VerificationTest — `CAPABILITY_FAILURE: VerificationTest unevaluated - VerificationTest is not implemented in Mathics3`

Summary lines from the same output: `Required failures: 0` and `capabilities.wl: PASS - all REQUIRED operations SUPPORTED (optional failures above, if any, are explicit)`.

Notes on the optional list: Series was classed optional in anticipation that it might fail; in the actual run it is SUPPORTED, and it is recorded as SUPPORTED above. The three optional CAPABILITY_FAILURE lines are explicit records of unevaluated returns (the Head of the result remained the operation name) — they are a pass for honesty, not computed results.

The capability-failure exit path itself was separately probed before delivery with a small script that guards a `BitAnd` call the same way `normalize.wl` guards its required operations: it printed `CAPABILITY_FAILURE: BitAnd unevaluated` and exited 1 without reaching the following line. That probe was run in `/tmp` and is not part of the delivered outputs; the delivered scripts use the same two-step guard pattern (print the failure line, then `Exit[1]` in a separate `If`).

## Files delivered

- `wolfram/normalize.wl`
- `wolfram/capabilities.wl`
- `wolfram/run.sh` (executable)
- `wolfram/README.md`
- `wolfram/outputs/normalize.out`
- `wolfram/outputs/capabilities.out`
- `wolfram/outputs/version.txt`
- `reports/phase-wolfram.md` (this file)
