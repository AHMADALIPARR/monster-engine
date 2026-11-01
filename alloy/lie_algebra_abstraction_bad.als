/**
 * lie_algebra_abstraction_bad.als — NEGATIVE variant of
 * lie_algebra_abstraction.als.
 *
 * Same concrete structure — sl(2) over F5 with basis {H, E, F} plus the
 * zero element Z, coefficients as representatives in {-2..2}, bilinear
 * evaluation of double brackets on basis triples — but with ONE
 * independent structure constant perturbed: [H, E] = 1E instead of 2E
 * (and, to keep the table antisymmetric, [E, H] = -1E instead of -2E).
 * Every other table entry is the genuine sl(2) entry.
 *
 * Why this breaks Jacobi: for the sl(2) target pattern, the independent
 * Jacobi component on the triple (H, E, F) along H equals c * (a + b),
 * where a = kk[H][E], b = kk[H][F], c = kk[E][F]. Genuine sl(2) has
 * 1 * (2 + (-2)) = 0; the perturbed table has 1 * (1 + (-2)) = -1, which
 * is nonzero in F5 (and as an integer), so the Jacobi identity fails.
 *
 * Expected behaviour: the JacobiIdentity check FINDS a counterexample
 * (result SAT), while BracketAntisymmetric still finds none (result
 * UNSAT) — antisymmetry was deliberately preserved so that Jacobi is the
 * identity that fails.
 *
 * Finite abstraction only; no claim about the Monster group.
 */
module lie_algebra_abstraction_bad

abstract sig Basis {}
one sig H extends Basis {}
one sig E extends Basis {}
one sig F extends Basis {}
one sig Z extends Basis {}  -- the zero vector

one sig Alg {
  brT: Basis -> Basis -> one Basis,
  brK: Basis -> Basis -> one Int
}

fun kk[a, b: Basis]: Int { Alg.brK[a][b] }
fun tt[a, b: Basis]: Basis { Alg.brT[a][b] }

fact PerturbedTable {
  -- brackets with H; BROKEN entry: kk[H][E] = 1 (genuine sl(2): 2)
  tt[H][H] = Z and kk[H][H] = 0
  tt[H][E] = E and kk[H][E] = 1
  tt[H][F] = F and kk[H][F] = -2
  tt[H][Z] = Z and kk[H][Z] = 0
  -- brackets with E; BROKEN partner entry: kk[E][H] = -1 (genuine: -2),
  -- changed only so that antisymmetry is preserved
  tt[E][H] = E and kk[E][H] = -1
  tt[E][E] = Z and kk[E][E] = 0
  tt[E][F] = H and kk[E][F] = 1
  tt[E][Z] = Z and kk[E][Z] = 0
  -- brackets with F (genuine)
  tt[F][H] = F and kk[F][H] = 2
  tt[F][E] = H and kk[F][E] = -1
  tt[F][F] = Z and kk[F][F] = 0
  tt[F][Z] = Z and kk[F][Z] = 0
  -- the zero vector brackets trivially with everything
  tt[Z][H] = Z and kk[Z][H] = 0
  tt[Z][E] = Z and kk[Z][E] = 0
  tt[Z][F] = Z and kk[Z][F] = 0
  tt[Z][Z] = Z and kk[Z][Z] = 0
}

fun termAlong[a, b, c, u: Basis]: Int {
  tt[tt[a][b]][c] = u => mul[kk[a][b], kk[tt[a][b]][c]] else 0
}

assert BracketAntisymmetric {
  all a, b: Basis |
    tt[a][b] = tt[b][a] and kk[b][a] = sub[0, kk[a][b]]
}

assert JacobiIdentity {
  all a, b, c, u: Basis |
    add[add[termAlong[a, b, c, u], termAlong[b, c, a, u]],
        termAlong[c, a, b, u]] = 0
}

check BracketAntisymmetric for 4 but 6 Int
-- EXPECTED: SAT (the perturbed table is a counterexample to Jacobi)
check JacobiIdentity for 4 but 6 Int

-- exhibits the perturbed entry directly
pred ShowPerturbedEntry {
  tt[H][E] = E and kk[H][E] = 1
}
run ShowPerturbedEntry for 4 but 6 Int
