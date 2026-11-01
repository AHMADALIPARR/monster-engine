/**
 * lie_algebra_abstraction.als — a concrete finite Lie bracket table
 * (valid form).
 *
 * The algebra encoded is sl(2) over the field F5: the 3-dimensional Lie
 * algebra with basis {H, E, F} and brackets
 *     [H, E] = 2E,   [H, F] = -2F,   [E, F] = H,
 * brackets of basis elements with themselves equal to zero, extended
 * antisymmetrically. Coefficients are written as integer representatives
 * in {-2, -1, 0, 1, 2} of elements of F5.
 *
 * The element set of the model is the basis together with a zero element
 * Z. The table (brT = target basis element or Z, brK = coefficient) is the
 * table of the bilinear extension restricted to basis pairs: the double
 * bracket [[a, b], c] of basis elements is evaluated as
 * brK[a][b] * brK[brT[a][b]][c] on the single basis element
 * brT[brT[a][b]][c], which is exactly bilinearity. The Jacobi assertion
 * below quantifies over all basis triples and all components; since the
 * table is fully pinned by facts, each check is a finite computation over
 * that pinned table.
 *
 * Integer scope: coefficients lie in {-2..2}, products in {-4..4}, and
 * Jacobi component sums in {-12..12}; checks use 6-bit integers
 * (-32..31), so no intermediate sum overflows. A component sum that is 0
 * as an integer is 0 in F5.
 *
 * Finite abstraction only: this is the classical 3-dimensional algebra
 * sl(2) over F5, used as a concrete test structure. It makes no claim
 * about the Monster group or any Lie algebra attached to it.
 */
module lie_algebra_abstraction

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

fact Sl2TableOverF5 {
  -- brackets with H
  tt[H][H] = Z and kk[H][H] = 0
  tt[H][E] = E and kk[H][E] = 2
  tt[H][F] = F and kk[H][F] = -2
  tt[H][Z] = Z and kk[H][Z] = 0
  -- brackets with E
  tt[E][H] = E and kk[E][H] = -2
  tt[E][E] = Z and kk[E][E] = 0
  tt[E][F] = H and kk[E][F] = 1
  tt[E][Z] = Z and kk[E][Z] = 0
  -- brackets with F
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

-- coefficient of the double bracket [[a, b], c] along basis element u,
-- using bilinearity: [[a,b],c] = kk[a][b] * [tt[a][b], c]
fun termAlong[a, b, c, u: Basis]: Int {
  tt[tt[a][b]][c] = u => mul[kk[a][b], kk[tt[a][b]][c]] else 0
}

assert BracketAntisymmetric {
  all a, b: Basis |
    tt[a][b] = tt[b][a] and kk[b][a] = sub[0, kk[a][b]]
}

assert BracketWithSelfIsZero {
  all a: Basis | tt[a][a] = Z and kk[a][a] = 0
}

assert JacobiIdentity {
  all a, b, c, u: Basis |
    add[add[termAlong[a, b, c, u], termAlong[b, c, a, u]],
        termAlong[c, a, b, u]] = 0
}

check BracketAntisymmetric for 4 but 6 Int
check BracketWithSelfIsZero for 4 but 6 Int
check JacobiIdentity for 4 but 6 Int

-- the pinned table itself, exhibiting the sl(2) structure constants
pred ShowSl2Table {
  tt[E][F] = H and kk[E][F] = 1
  tt[H][E] = E and kk[H][E] = 2
  tt[H][F] = F and kk[H][F] = -2
}
run ShowSl2Table for 4 but 6 Int
