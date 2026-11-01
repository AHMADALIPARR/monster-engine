#!/usr/bin/env python3
"""Independent cross-check for the Uiua kernels in this directory.

Reads the captured Uiua stdout files in outputs/, parses the numbers
printed after each label, and compares them against values computed
here from scratch with plain Python loops (standard library only).
Prints Uiua value and independently computed value side by side for
every check and exits nonzero if any of them differ.
"""

import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "outputs")

FAILURES = []


def parse_labelled(filename):
    """Return {label: [numbers]} from a captured Uiua output file.

    Labels are printed on their own line, followed by one value line.
    Uiua prints negative numbers with a leading '-' in &p output and
    arrays in bracket notation; every number in the value chunk is
    collected in order.
    """
    with open(os.path.join(OUT, filename), encoding="utf-8") as fh:
        lines = [ln.strip() for ln in fh if ln.strip()]
    result = {}
    label = None
    for ln in lines:
        if re.fullmatch(r"[a-z][a-z0-9_]*", ln):
            label = ln
            result[label] = []
        elif label is not None:
            for tok in re.findall(r"-?\d+(?:\.\d+)?", ln):
                result[label].append(float(tok))
    return result


def as_ints(nums):
    out = []
    for n in nums:
        if n != int(n):
            raise ValueError(f"non-integer value printed by Uiua: {n}")
        out.append(int(n))
    return out


def report(name, uiua_vals, expected_vals):
    uiua_vals = list(uiua_vals)
    expected_vals = list(expected_vals)
    ok = uiua_vals == expected_vals
    print(f"{'PASS' if ok else 'FAIL'}  {name}")
    print(f"      Uiua:        {uiua_vals}")
    print(f"      independent: {expected_vals}")
    if not ok:
        FAILURES.append(name)


def matmul(a, b):
    """Plain-loop matrix product of two list-of-rows matrices."""
    rows, inner, cols = len(a), len(b), len(b[0])
    out = [[0] * cols for _ in range(rows)]
    for i in range(rows):
        for j in range(cols):
            total = 0
            for k in range(inner):
                total += a[i][k] * b[k][j]
            out[i][j] = total
    return out


def flatten(mat):
    return [x for row in mat for x in row]


# ---------------------------------------------------------------- jacobi
# Structure constants built independently from the bracket table of
# so(3): +1 for cyclic (i, j, k), -1 for anticyclic, else 0.
def structure_constants(perturbed):
    cyclic = {(0, 1, 2), (1, 2, 0), (2, 0, 1)}
    anticyclic = {(0, 2, 1), (2, 1, 0), (1, 0, 2)}
    c = [[[0] * 3 for _ in range(3)] for _ in range(3)]
    for i in range(3):
        for j in range(3):
            for k in range(3):
                if (i, j, k) in cyclic:
                    c[i][j][k] = 1
                elif (i, j, k) in anticyclic:
                    c[i][j][k] = -1
    if perturbed:
        c[0][1][2] = 2
    return c


def jacobi_max_abs(c):
    best = 0
    for i in range(3):
        for j in range(3):
            for k in range(3):
                for l in range(3):
                    total = 0
                    for m in range(3):
                        total += (
                            c[i][j][m] * c[m][k][l]
                            + c[j][k][m] * c[m][i][l]
                            + c[k][i][m] * c[m][j][l]
                        )
                    best = max(best, abs(total))
    return best


got = parse_labelled("jacobi.txt")
report(
    "jacobi bracket [e0,e1]",
    as_ints(got["bracket_e0_e1"]),
    structure_constants(False)[0][1],
)
report(
    "jacobi bracket [e1,e2]",
    as_ints(got["bracket_e1_e2"]),
    structure_constants(False)[1][2],
)
report(
    "jacobi max abs residual, unperturbed so(3)",
    as_ints(got["jacobi_max_abs_unperturbed"]),
    [jacobi_max_abs(structure_constants(False))],
)
report(
    "jacobi max abs residual, perturbed C_012 = 2",
    as_ints(got["jacobi_max_abs_perturbed"]),
    [jacobi_max_abs(structure_constants(True))],
)

# --------------------------------------------------------------- jcoeff
coeffs = [744, 196884, 21493760, 864299970]
partial = []
run = 0
for c in coeffs:
    run += c
    partial.append(run)
diffs = [coeffs[i + 1] - coeffs[i] for i in range(len(coeffs) - 1)]

got = parse_labelled("jcoeff.txt")
report("j coefficients", as_ints(got["coefficients"]), coeffs)
report("j McKay 196884 - 1", as_ints(got["mckay_difference"]), [coeffs[1] - 1])
report("j partial sums", as_ints(got["partial_sums"]), partial)
report("j consecutive differences", as_ints(got["consecutive_differences"]), diffs)

# ------------------------------------------------------------ transforms
vectors = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [0, -1, 2]]
perm = [[0, 1, 0], [0, 0, 1], [1, 0, 0]]
perm_t = [[perm[j][i] for j in range(3)] for i in range(3)]
proj = [[1, 0, 0], [0, 1, 0], [0, 0, 0]]
forward = matmul(vectors, perm)
back = matmul(forward, perm_t)
res_perm = max(
    abs(back[i][j] - vectors[i][j]) for i in range(4) for j in range(3)
)
dropped = matmul(matmul(vectors, proj), proj)
res_proj = max(
    abs(dropped[i][j] - vectors[i][j]) for i in range(4) for j in range(3)
)

got = parse_labelled("transforms.txt")
report(
    "transforms forward (z, x, y)",
    as_ints(got["forward_transformed"]),
    flatten(forward),
)
report(
    "transforms permutation roundtrip residual",
    as_ints(got["permutation_roundtrip_max_abs_residual"]),
    [res_perm],
)
report(
    "transforms projection roundtrip residual",
    as_ints(got["projection_roundtrip_max_abs_residual"]),
    [res_proj],
)

# ---------------------------------------------------------- equivariance
test = [[1, 2], [3, 4]]


def flip_rows(a):
    return [row[:] for row in reversed(a)]


def flip_cols(a):
    return [list(reversed(row)) for row in a]


def flip_both(a):
    return flip_rows(flip_cols(a))


def transpose(a):
    return [[a[j][i] for j in range(2)] for i in range(2)]


def max_abs_diff(a, b):
    return max(abs(a[i][j] - b[i][j]) for i in range(2) for j in range(2))


got = parse_labelled("equivariance.txt")
report(
    "equivariance flip-both array",
    as_ints(got["flip_both"]),
    flatten(flip_both(test)),
)
report(
    "equivariance residual rows vs cols order",
    as_ints(got["residual_rows_cols"]),
    [max_abs_diff(flip_rows(flip_cols(test)), flip_cols(flip_rows(test)))],
)
report(
    "equivariance residual rows vs both order",
    as_ints(got["residual_rows_both"]),
    [max_abs_diff(flip_rows(flip_both(test)), flip_both(flip_rows(test)))],
)
report(
    "equivariance residual cols vs both order",
    as_ints(got["residual_cols_both"]),
    [max_abs_diff(flip_cols(flip_both(test)), flip_both(flip_cols(test)))],
)
report(
    "equivariance residual rows twice vs original",
    as_ints(got["residual_rows_twice_vs_original"]),
    [max_abs_diff(flip_rows(flip_rows(test)), test)],
)
report(
    "equivariance contrast residual transpose vs rows",
    as_ints(got["contrast_residual_transpose_rows"]),
    [max_abs_diff(flip_rows(transpose(test)), transpose(flip_rows(test)))],
)

# ------------------------------------------------------------------ done
if FAILURES:
    print(f"\n{len(FAILURES)} check(s) FAILED: {', '.join(FAILURES)}")
    sys.exit(1)
print("\nAll checks passed.")
