/**
 * representation_composition_bad.als — NEGATIVE variant of
 * representation_composition.als.
 *
 * Same finite abstraction (finite magmas EA, EB, EC and maps between them;
 * no claim about the actual Monster group), but BROKEN: f and g are
 * required to be homomorphisms, while h is an arbitrary map that is merely
 * CLAIMED to be the composite representation. Nothing ties h to g after f,
 * and h need not preserve the operation tables.
 *
 * Expected behaviour: the CompositionOfHomomorphismsIsHomomorphism check
 * FINDS a counterexample (result SAT) — an instance where f and g are
 * homomorphisms but the claimed composite h is not (concretely realisable
 * already on 2-element tables: with xor tables and f = g = identity, the
 * constant map to the non-identity element is not a homomorphism).
 */
module representation_composition_bad

sig EA {}
sig EB {}
sig EC {}

one sig MA { op: EA -> EA -> one EA }
one sig MB { op: EB -> EB -> one EB }
one sig MC { op: EC -> EC -> one EC }

one sig Maps {
  f: EA -> one EB,
  g: EB -> one EC,
  h: EA -> one EC
}

pred HomF {
  all x, y: EA | Maps.f[MA.op[x][y]] = MB.op[Maps.f[x]][Maps.f[y]]
}
pred HomG {
  all x, y: EB | Maps.g[MB.op[x][y]] = MC.op[Maps.g[x]][Maps.g[y]]
}
pred HomH {
  all x, y: EA | Maps.h[MA.op[x][y]] = MC.op[Maps.h[x]][Maps.h[y]]
}

-- f and g are genuine homomorphisms; h is unconstrained (the broken claim)
fact FGenuinelyHomomorphic {
  HomF and HomG
  -- BROKEN: no fact defines h as the composition, and HomH is not imposed.
}

assert CompositionOfHomomorphismsIsHomomorphism {
  (HomF and HomG) implies HomH
}

-- EXPECTED: SAT (a counterexample exists within scope)
check CompositionOfHomomorphismsIsHomomorphism for 3

-- exhibits one concrete failure: homomorphic f, g with a non-homomorphic h
pred NonHomomorphicClaimedMap {
  HomF and HomG and not HomH
}
run NonHomomorphicClaimedMap for 3
