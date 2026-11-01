# Uiua array kernels — MONSTER-BRIDGE Phase 7

Four array kernels written in native Uiua 0.19.1, each printing its
results with `&p` to stdout, plus a runner and an independent
cross-checker. Every number below is taken from an actual run in this
workspace and is verified by `check.py`, which recomputes each expected
value from scratch in plain Python (standard library only, explicit
loops) and compares it against the numbers the Uiua programs printed.

## Files

- `jacobi.ua` — Jacobi residual of the so(3) Lie algebra, and of a
  perturbed constant table.
- `jcoeff.ua` — arithmetic on the first j-function coefficients.
- `transforms.ua` — forward/inverse consistency of a reversible
  permutation transform versus an irreversible projection.
- `equivariance.ua` — composition consistency of the Klein four-group
  of flips acting on a 2x2 array.
- `run_all.sh` — runs all four kernels, captures stdout to `outputs/`,
  then runs the checker.
- `check.py` — independent cross-check; exits nonzero on any mismatch.
- `outputs/` — captured stdout (`<kernel>.txt`) and stderr
  (`<kernel>.stderr.txt`, empty for all four kernels: the programs
  print everything with `&p` and leave the stack empty) from the most
  recent run.

## Exact commands

Tool: Uiua 0.19.1 at `~/workspace/.tools/uiua/uiua`
(`uiua --version` prints `uiua 0.19.1`).

Run everything, with cross-check:

```sh
cd ~/workspace/monster-engine
bash uiua/run_all.sh
```

The canonical per-file invocation is

```sh
~/workspace/.tools/uiua/uiua run uiua/jacobi.ua
```

(and likewise for the other three files). `run_all.sh` uses
`uiua run --no-format --no-color <file>.ua` per file: `--no-format`
keeps `uiua run` from rewriting the source files as it runs them, and
`--no-color` keeps the captured output plain. The checker alone is
`python3 uiua/check.py`, run against the files in `uiua/outputs/`.

Benchmark: the full `bash uiua/run_all.sh` run takes 0.57 s wall time
(`/usr/bin/time -p`: real 0.57, user 0.06, sys 0.32). Full record in
`benchmarks/uiua-benchmark.txt` at the repository root.

## What each kernel computes, and its output as run

### jacobi.ua

Structure constants of so(3) (the cross-product algebra,
[e0, e1] = e2, [e1, e2] = e0, [e2, e0] = e1, antisymmetric completion)
are the Levi-Civita tensor C_ijk. The kernel forms
G_abcd = sum_m C_abm * C_mcd as a single matrix product — C reshaped to
9x3 times C reshaped to 3x9, via `⊞` (table) of the dot product
`/+ ×` — then adds G read as (i, j, k, l), (j, k, i, l), and
(k, i, j, l) (the last two readings applied with `⊏` select and
broadcast-built index arrays) to form the full Jacobi residual tensor
J_ijkl = sum_m (C_ijm C_mkl + C_jkm C_mil + C_kim C_mjl), and prints
its maximum absolute component. The same computation is then run on a
perturbed table with C_012 changed from 1 to 2.

Output as run (`outputs/jacobi.txt`):

```
bracket_e0_e1
[0 0 1]
bracket_e1_e2
[1 0 0]
jacobi_max_abs_unperturbed
0
jacobi_max_abs_perturbed
1
```

Side-by-side cross-check: Uiua prints 0 and 1; `check.py` computes 0
and 1 independently (it builds C from the bracket table directly and
evaluates J with four nested loops). So(3) satisfies the Jacobi
identity exactly, and the perturbed table does not — the residual
discriminates.

### jcoeff.ua

Coefficient array [744, 196884, 21493760, 864299970]: established
published values, the constant term and first three q-coefficients of
the modular j-function (j(tau) = 1/q + 744 + 196884 q + 21493760 q^2 +
864299970 q^3 + ...). The kernel prints the array, the McKay
difference 196884 - 1 = 196883 (computed as a select of the second
coefficient minus 1), the partial sums (scan `\+`), and the
consecutive differences. All values are integers below 2^53, hence
exactly representable in Uiua's double-precision floats.

Output as run (`outputs/jcoeff.txt`):

```
coefficients
[744 196884 21493760 864299970]
mckay_difference
196883
partial_sums
[744 197628 21691388 885991358]
consecutive_differences
[196140 21296876 842806210]
```

Cross-check: `check.py` recomputes all four lines in Python integer
arithmetic; all agree exactly.

### transforms.ua

Four row vectors V = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0, -1, 2]] are
transformed by matrices applied on the right (table/dot-product matrix
product). Reversible case: the cyclic permutation matrix P for
(x, y, z) -> (z, x, y); its inverse is its transpose, so P then
transpose(P) must reconstruct V exactly. Irreversible case: the
projection Q for (x, y, z) -> (x, y, 0), followed by its transpose,
cannot restore the dropped coordinate.

Output as run (`outputs/transforms.txt`):

```
forward_transformed
[[3 1 2] [6 4 5] [9 7 8] [2 0 -1]]
permutation_roundtrip_max_abs_residual
0
projection_roundtrip_max_abs_residual
9
```

Cross-check: `check.py` recomputes the products and residuals with
plain loops; the projection residual 9 is the largest dropped third
coordinate in V, as expected. The same residual computation returns 0
for the reversible transform and 9 for the irreversible one.

### equivariance.ua

The Klein four-group Z2 x Z2 acts on M = [[1, 2], [3, 4]] by index
permutations: identity, flip-rows (`⇌`, reverse), flip-cols (`≡⇌`,
reverse applied to each row), flip-both (their composition, the
180-degree rotation [[4, 3], [2, 1]]). The kernel composes each mixed
pair in both orders and prints the maximum absolute difference between
the orders, plus the involution check (flip-rows twice versus M). As a
contrast it also composes flip-rows with the transpose — a symmetry
outside this group — in both orders.

Output as run (`outputs/equivariance.txt`):

```
flip_both
[[4 3] [2 1]]
residual_rows_cols
0
residual_rows_both
0
residual_cols_both
0
residual_rows_twice_vs_original
0
contrast_residual_transpose_rows
3
```

Cross-check: `check.py` recomputes every line with Python list
operations; all agree. The commuting pairs of the Klein four give
residual 0, while flip-rows against the transpose gives 3, so the
zero residuals are not vacuous.

## Cross-check results

`bash uiua/run_all.sh` ends with the checker reporting 17 checks, all
PASS, and exit code 0:

- jacobi: bracket [e0, e1], bracket [e1, e2], unperturbed residual,
  perturbed residual — 4 PASS
- jcoeff: coefficients, McKay difference, partial sums, consecutive
  differences — 4 PASS
- transforms: forward array, permutation roundtrip residual,
  projection roundtrip residual — 3 PASS
- equivariance: flip-both array, three mixed-pair residuals,
  involution residual, transpose contrast residual — 6 PASS

The checker's failure path was itself verified: with one captured
output value altered by hand, `check.py` reports that check as FAIL
and exits 1.

## Uiua 0.19.1 semantics relied on (each validated by execution)

- `&p` prints a value to stdout followed by a newline; arrays print in
  bracket notation on one line. Any values a program leaves on the
  stack are printed by `uiua run` to stderr instead, so these programs
  print every result explicitly with `&p` and leave the stack empty.
- Dyadic `-` takes its operands in stack order: `- X Y` evaluates to
  Y - X. The subtraction expressions in these kernels are ordered
  accordingly (and documented per file); residuals take absolute
  values, where the order is immaterial.
- A 2x2 array literal is written with underscores between the elements
  of a row and spaces between rows, e.g. `[1_2 3_4]`. Writing
  `[1 2;3 4]` instead produces a flat array of shape [4] in 0.19.1;
  the kernels use the underscore form (and `↯` reshape elsewhere).
- `⊞(/+ ×) A ⍉B` is the matrix product A * B: table applies the dot
  product `/+ ×` to each combination of a row of A and a row of
  transpose(B), i.e. a column of B.
- Binding names in 0.19.1 are letters only (a name such as `I4` is a
  parse error), and re-binding a name from an expression mentioning
  the name itself is treated as a recursive function definition, so
  index arrays here are built in a single expression per binding.
- `¯` prefixes negative literals; printed output uses `-`.
