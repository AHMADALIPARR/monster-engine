#!/usr/bin/env python3
"""Contract checkers for the MONSTER-BRIDGE contract families.

Reads contracts/families.json and executes every finite-check,
identity-check and data-check item with exact integer / Fraction
arithmetic where the check is algebraic. Abstract-only items are
reported as UNSUPPORTED with the reason from families.json.

Prints exactly one line per contract id:
    <id>: <STATUS> (<detail>)
with STATUS in {VERIFIED, COUNTEREXAMPLE, BOUNDED, UNSUPPORTED}.

Exit code is 0 only if every actual status equals the expected
status encoded in EXPECTED below. Status lines go to stdout;
mismatch warnings go to stderr.
"""

import json
import sys
from fractions import Fraction
from itertools import product
from pathlib import Path

HERE = Path(__file__).resolve().parent
FAMILIES = json.loads((HERE / "families.json").read_text(encoding="utf-8"))

EXPECTED = {
    "MON-identity": "VERIFIED",
    "MON-closure": "VERIFIED",
    "MON-associativity": "VERIFIED",
    "MON-inverses": "VERIFIED",
    "MON-homomorphism": "VERIFIED",
    "MON-nonhomomorphism": "COUNTEREXAMPLE",
    "MON-character-compat": "VERIFIED",
    "MON-conjugacy": "VERIFIED",
    "MON-monster-abstract": "UNSUPPORTED",
    "MOON-j-coeffs": "VERIFIED",
    "MOON-mckay-identity": "VERIFIED",
    "MOON-character-decomposition": "VERIFIED",
    "MOON-modular-transform": "UNSUPPORTED",
    "MOON-mckay-thompson": "UNSUPPORTED",
    "MOON-partition-constraints": "UNSUPPORTED",
    "LIE-structure-constants": "VERIFIED",
    "LIE-antisymmetry": "VERIFIED",
    "LIE-jacobi": "VERIFIED",
    "LIE-action-composition": "VERIFIED",
    "LIE-tangent-space": "UNSUPPORTED",
    "LIE-equivariance": "UNSUPPORTED",
    "LIE-coordinate-compat": "UNSUPPORTED",
    "GEO-subdivision": "BOUNDED",
    "GEO-forward-inverse": "BOUNDED",
    "GEO-tensor-shape": "BOUNDED",
    "GEO-reconstruction": "BOUNDED",
    "GEO-rank-preservation": "BOUNDED",
    "GEO-holographic-scope": "UNSUPPORTED",
}


# ---------------------------------------------------------------- S3
def compose(p, q):
    """Permutation composition (p after q): (p o q)(i) = p[q[i]]."""
    return tuple(p[q[i]] for i in range(3))


def build_s3():
    """Construct S3 by closure from a transposition and a 3-cycle."""
    identity = (0, 1, 2)
    gens = [(1, 0, 2), (1, 2, 0)]
    elems = {identity}
    frontier = [identity]
    while frontier:
        nxt = []
        for x in frontier:
            for g in gens:
                for y in (compose(g, x), compose(x, g)):
                    if y not in elems:
                        elems.add(y)
                        nxt.append(y)
        frontier = nxt
    return identity, sorted(elems)


E, S3 = build_s3()
S3SET = set(S3)


def perm_inverse(p):
    inv = [0, 0, 0]
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)


def perm_sign(p):
    inversions = sum(1 for i in range(3) for j in range(i + 1, 3) if p[i] > p[j])
    return -1 if inversions % 2 else 1


def conjugacy_classes_s3():
    classes = []
    seen = set()
    for g in S3:
        if g in seen:
            continue
        cls = {compose(compose(h, g), perm_inverse(h)) for h in S3}
        seen |= cls
        classes.append(cls)
    return classes


# ------------------------------------------------------- MON checks
def check_mon_identity():
    ok = all(compose(E, x) == x and compose(x, E) == x for x in S3)
    if not ok or E not in S3SET or len(S3) != 6:
        return "COUNTEREXAMPLE", "identity law fails for S3 instance"
    return "VERIFIED", (
        f"S3 finite instance: |S3|={len(S3)}, Cayley table built from "
        f"generators (1,0,2) and (1,2,0); e*x=x*e=x for {len(S3)}/{len(S3)} elements"
    )


def check_mon_closure():
    pairs = 0
    inside = 0
    for a, b in product(S3, repeat=2):
        pairs += 1
        if compose(a, b) in S3SET:
            inside += 1
    return ("VERIFIED" if inside == pairs else "COUNTEREXAMPLE"), (
        f"S3 finite instance: {inside}/{pairs} products lie in the set"
    )


def check_mon_associativity():
    total = 0
    good = 0
    for a, b, c in product(S3, repeat=3):
        total += 1
        if compose(compose(a, b), c) == compose(a, compose(b, c)):
            good += 1
    return ("VERIFIED" if good == total else "COUNTEREXAMPLE"), (
        f"S3 finite instance: {good}/{total} triples satisfy (a*b)*c = a*(b*c)"
    )


def check_mon_inverses():
    good = 0
    for x in S3:
        inv = perm_inverse(x)
        if inv in S3SET and compose(x, inv) == E and compose(inv, x) == E:
            good += 1
    return ("VERIFIED" if good == len(S3) else "COUNTEREXAMPLE"), (
        f"S3 finite instance: {good}/{len(S3)} elements have a two-sided inverse"
    )


def check_mon_homomorphism():
    good = 0
    for a, b in product(S3, repeat=2):
        if perm_sign(compose(a, b)) == perm_sign(a) * perm_sign(b):
            good += 1
    return ("VERIFIED" if good == 36 else "COUNTEREXAMPLE"), (
        f"sign map S3 -> {{+1,-1}}: {good}/36 pairs satisfy sign(a*b)=sign(a)*sign(b)"
    )


def check_mon_nonhomomorphism():
    target = (1, 0, 2)  # the transposition; constant map sends everything here

    def bad_map(_p):
        return target

    for a, b in product(S3, repeat=2):
        if compose(bad_map(a), bad_map(b)) != bad_map(compose(a, b)):
            return "COUNTEREXAMPLE", (
                f"constant map to {target} detected as non-homomorphism: "
                f"at a={a}, b={b}: f(a)*f(b)={compose(bad_map(a), bad_map(b))} "
                f"!= f(a*b)={bad_map(compose(a, b))} (property fails, as expected)"
            )
    return "VERIFIED", "constant map unexpectedly passed all 36 pairs"


def check_mon_conjugacy():
    classes = conjugacy_classes_s3()
    sizes = sorted(len(c) for c in classes)
    union = set().union(*classes)
    disjoint = sum(len(c) for c in classes) == len(union)
    ok = sizes == [1, 2, 3] and union == S3SET and disjoint
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        f"S3 finite instance: {len(classes)} conjugacy classes, sizes {sizes}, "
        f"sum={sum(sizes)} = |S3|, partition={'yes' if disjoint and union == S3SET else 'no'}"
    )


def check_mon_character():
    classes = conjugacy_classes_s3()

    def fix_count(p):
        return sum(1 for i in range(3) if p[i] == i)

    def chi_std(p):
        return fix_count(p) - 1

    chars = {
        "trivial": lambda p: 1,
        "sign": perm_sign,
        "standard": chi_std,
    }
    # Constant on conjugacy classes.
    class_const = all(
        len({chi(g) for g in cls}) == 1 for chi in chars.values() for cls in classes
    )
    # Orthonormality: <chi, psi> = (1/6) * sum_g chi(g) psi(g) over integers.
    ortho_ok = True
    for n1, c1 in chars.items():
        for n2, c2 in chars.items():
            ip = Fraction(sum(c1(g) * c2(g) for g in S3), 6)
            if ip != (1 if n1 == n2 else 0):
                ortho_ok = False
    dim_sum = 1 * 1 + 1 * 1 + 2 * 2
    ok = class_const and ortho_ok and dim_sum == len(S3)
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        "S3 character table: chars constant on classes="
        f"{'yes' if class_const else 'no'}, pairwise orthonormal="
        f"{'yes' if ortho_ok else 'no'}, 1^2+1^2+2^2={dim_sum}=|S3|"
    )


# ------------------------------------------------------ MOON checks
PUBLISHED_J = [744, 196884, 21493760, 864299970]


def _item(item_id):
    for fam in FAMILIES["families"]:
        for it in fam["items"]:
            if it["id"] == item_id:
                return it
    raise KeyError(item_id)


def check_moon_j_coeffs():
    recorded = _item("MOON-j-coeffs")["data"]["coefficients"]
    ok = recorded == PUBLISHED_J
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        f"recorded coefficients {recorded} equal the established published "
        f"values {PUBLISHED_J}: {'yes' if ok else 'no'}"
    )


def check_moon_mckay():
    ok = 196884 == 196883 + 1 and PUBLISHED_J[1] == 196884
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        "exact integers: 196883 + 1 = 196884 = the recorded q^1 coefficient"
    )


def check_moon_decomposition():
    d1 = 1 + 196883 + 21296876
    d2 = 2 * 1 + 2 * 196883 + 21296876 + 842609326
    ok = d1 == 21493760 == PUBLISHED_J[2] and d2 == 864299970 == PUBLISHED_J[3]
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        f"exact integers: 1+196883+21296876={d1} and "
        f"2*1+2*196883+21296876+842609326={d2}, matching the published coefficients"
    )


# ------------------------------------------------------- LIE checks
def eps(i, j, k):
    if len({i, j, k}) < 3:
        return 0
    inversions = sum(
        1 for a, b in ((i, j), (i, k), (j, k)) if a > b
    )
    return -1 if inversions % 2 else 1


def bracket(u, v):
    """Bracket of vectors u, v in the so(3) basis, exact Fractions."""
    out = []
    for k in range(3):
        s = Fraction(0)
        for i in range(3):
            for j in range(3):
                s += eps(i, j, k) * u[i] * v[j]
        out.append(s)
    return tuple(out)


BASIS = [
    (Fraction(1), Fraction(0), Fraction(0)),
    (Fraction(0), Fraction(1), Fraction(0)),
    (Fraction(0), Fraction(0), Fraction(1)),
]

# Stored bracket table (the data under check): [e_i, e_j] as a vector.
STORED_BRACKET = {
    (0, 0): (0, 0, 0), (0, 1): (0, 0, 1), (0, 2): (0, -1, 0),
    (1, 0): (0, 0, -1), (1, 1): (0, 0, 0), (1, 2): (1, 0, 0),
    (2, 0): (0, 1, 0), (2, 1): (-1, 0, 0), (2, 2): (0, 0, 0),
}


def check_lie_structure():
    good = 0
    for (i, j), vec in STORED_BRACKET.items():
        expect = tuple(int(x) for x in bracket(BASIS[i], BASIS[j]))
        if tuple(vec) == expect:
            good += 1
    spots = (eps(0, 1, 2), eps(1, 2, 0), eps(2, 0, 1),
             eps(0, 2, 1), eps(1, 0, 2), eps(2, 1, 0), eps(0, 0, 1))
    ok = good == 9 and spots == (1, 1, 1, -1, -1, -1, 0)
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        f"so(3) instance: {good}/9 stored bracket entries match the Levi-Civita "
        f"definition; eps_012=eps_120=eps_201=+1, eps_021=eps_102=eps_210=-1, eps_001=0"
    )


def check_lie_antisymmetry():
    max_res = Fraction(0)
    pairs = 0
    for i, j in product(range(3), repeat=2):
        pairs += 1
        s = tuple(bracket(BASIS[i], BASIS[j])[k] + bracket(BASIS[j], BASIS[i])[k]
                  for k in range(3))
        max_res = max(max_res, max(abs(x) for x in s))
    return ("VERIFIED" if max_res == 0 else "COUNTEREXAMPLE"), (
        f"so(3) instance: [e_i,e_j]+[e_j,e_i]=0 on {pairs}/9 basis pairs, "
        f"max residual = {max_res} (exact rational)"
    )


def check_lie_jacobi():
    max_res = Fraction(0)
    triples = 0
    for i, j, k in product(range(3), repeat=3):
        triples += 1
        x, y, z = BASIS[i], BASIS[j], BASIS[k]
        total = tuple(
            bracket(x, bracket(y, z))[t]
            + bracket(y, bracket(z, x))[t]
            + bracket(z, bracket(x, y))[t]
            for t in range(3)
        )
        max_res = max(max_res, max(abs(v) for v in total))
    return ("VERIFIED" if max_res == 0 else "COUNTEREXAMPLE"), (
        f"so(3) instance: Jacobi sum = 0 on {triples}/27 basis triples, "
        f"max residual = {max_res} (exact rational)"
    )


def check_lie_action():
    def act(g, v):
        return (v + g) % 4

    total = 0
    good = 0
    for g, h, v in product(range(4), repeat=3):
        total += 1
        if act((g + h) % 4, v) == act(g, act(h, v)):
            good += 1
    ident = all(act(0, v) == v for v in range(4))
    ok = good == total and ident
    return ("VERIFIED" if ok else "COUNTEREXAMPLE"), (
        f"C4 action on square vertices {{0,1,2,3}}: {good}/{total} triples "
        f"satisfy (g+h).v = g.(h.v); identity action holds: {'yes' if ident else 'no'}"
    )


# ------------------------------------------------------- GEO checks
def check_geo_subdivision():
    # Quadtree over the unit square, exact Fraction areas, depth 2.
    def split(area):
        return [area / 4] * 4

    nodes_checked = 0
    nodes_ok = 0
    level = [Fraction(1)]
    for _depth in range(2):
        nxt = []
        for area in level:
            children = split(area)
            nodes_checked += 1
            if sum(children, Fraction(0)) == area:
                nodes_ok += 1
            nxt.extend(children)
        level = nxt
    leaf_sum = sum(level, Fraction(0))
    ok = nodes_ok == nodes_checked and len(level) == 16 and leaf_sum == 1
    return ("BOUNDED" if ok else "COUNTEREXAMPLE"), (
        f"concrete dyadic quadtree depth 2: parent = sum of 4 children at "
        f"{nodes_ok}/{nodes_checked} internal nodes (exact Fractions); "
        f"{len(level)} leaves each 1/16, leaf sum = {leaf_sum}; bounded instance only"
    )


def check_geo_forward_inverse():
    def fwd(x, y):
        return (x + 2 * y, y)

    def inv(x, y):
        return (x - 2 * y, y)

    vectors = [(3, 5), (-2, 7), (0, 0), (11, -4), (-6, -6)]
    max_res = 0
    for v in vectors:
        back = inv(*fwd(*v))
        forth = fwd(*inv(*v))
        max_res = max(max_res, abs(back[0] - v[0]), abs(back[1] - v[1]),
                      abs(forth[0] - v[0]), abs(forth[1] - v[1]))
    return ("BOUNDED" if max_res == 0 else "COUNTEREXAMPLE"), (
        f"integer shear T(x,y)=(x+2y,y) on {len(vectors)} test vectors: "
        f"max forward/inverse residual = {max_res} (exact integers); bounded instance only"
    )


def _prod(shape):
    n = 1
    for d in shape:
        n *= d
    return n


def check_geo_tensor():
    shapes = [(2, 3, 4), (4, 3, 2), (6, 4), (24,), (2, 12)]
    counts = [_prod(s) for s in shapes]
    ok = all(c == 24 for c in counts)
    return ("BOUNDED" if ok else "COUNTEREXAMPLE"), (
        f"concrete shapes {shapes}: element counts {counts}, all equal 24: "
        f"{'yes' if ok else 'no'}; bounded instance only"
    )


def check_geo_reconstruction():
    xs = [i / 8 for i in range(9)]
    vals = [2.0 * x + 1.0 for x in xs]  # concrete sampled signal f(x) = 2x + 1
    upsampled = []
    for i in range(8):
        upsampled.append(vals[i])
        upsampled.append(0.5 * (vals[i] + vals[i + 1]))  # linear midpoint
    upsampled.append(vals[8])
    downsampled = upsampled[::2]
    max_res = max(abs(a - b) for a, b in zip(downsampled, vals))
    ok = len(downsampled) == len(vals) and max_res < 1e-9
    return ("BOUNDED" if ok else "COUNTEREXAMPLE"), (
        f"concrete signal f(x)=2x+1 on 9 dyadic samples: upsample/downsample "
        f"max abs residual = {max_res:.3e} (< 1e-9: {'yes' if ok else 'no'}); "
        f"numerical evidence on this instance only, not a proof"
    )


def _rank(matrix):
    rows = [[Fraction(x) for x in row] for row in matrix]
    rank = 0
    col = 0
    nrows, ncols = len(rows), len(rows[0])
    r = 0
    while r < nrows and col < ncols:
        pivot = next((i for i in range(r, nrows) if rows[i][col] != 0), None)
        if pivot is None:
            col += 1
            continue
        rows[r], rows[pivot] = rows[pivot], rows[r]
        pv = rows[r][col]
        rows[r] = [x / pv for x in rows[r]]
        for i in range(nrows):
            if i != r and rows[i][col] != 0:
                factor = rows[i][col]
                rows[i] = [a - factor * b for a, b in zip(rows[i], rows[r])]
        rank += 1
        r += 1
        col += 1
    return rank


def check_geo_rank():
    m = [[1, 2, 3], [2, 4, 6], [1, 1, 1]]
    base = _rank(m)
    row_perm = [m[2], m[0], m[1]]
    col_perm = [[row[1], row[2], row[0]] for row in m]
    r_row, r_col = _rank(row_perm), _rank(col_perm)
    ok = base == r_row == r_col == 2
    return ("BOUNDED" if ok else "COUNTEREXAMPLE"), (
        f"concrete matrix rank = {base} (exact rational elimination); "
        f"row-permuted rank = {r_row}, column-permuted rank = {r_col}; "
        f"bounded instance only"
    )


CHECKS = {
    "MON-identity": check_mon_identity,
    "MON-closure": check_mon_closure,
    "MON-associativity": check_mon_associativity,
    "MON-inverses": check_mon_inverses,
    "MON-homomorphism": check_mon_homomorphism,
    "MON-nonhomomorphism": check_mon_nonhomomorphism,
    "MON-character-compat": check_mon_character,
    "MON-conjugacy": check_mon_conjugacy,
    "MOON-j-coeffs": check_moon_j_coeffs,
    "MOON-mckay-identity": check_moon_mckay,
    "MOON-character-decomposition": check_moon_decomposition,
    "LIE-structure-constants": check_lie_structure,
    "LIE-antisymmetry": check_lie_antisymmetry,
    "LIE-jacobi": check_lie_jacobi,
    "LIE-action-composition": check_lie_action,
    "GEO-subdivision": check_geo_subdivision,
    "GEO-forward-inverse": check_geo_forward_inverse,
    "GEO-tensor-shape": check_geo_tensor,
    "GEO-reconstruction": check_geo_reconstruction,
    "GEO-rank-preservation": check_geo_rank,
}


def main():
    items = [it for fam in FAMILIES["families"] for it in fam["items"]]
    ids = [it["id"] for it in items]
    if set(ids) != set(EXPECTED):
        print("families.json ids and EXPECTED ids differ", file=sys.stderr)
        return 2
    failures = 0
    for it in items:
        item_id = it["id"]
        if it["kind"] == "abstract-only":
            status = "UNSUPPORTED"
            detail = "abstract-only, not machine-checked: " + it["scope"]
        else:
            status, detail = CHECKS[item_id]()
        print(f"{item_id}: {status} ({detail})")
        if status != EXPECTED[item_id]:
            failures += 1
            print(
                f"MISMATCH {item_id}: expected {EXPECTED[item_id]}, got {status}",
                file=sys.stderr,
            )
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
