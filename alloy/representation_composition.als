/**
 * representation_composition.als — composition of homomorphisms (valid form).
 *
 * Finite abstraction only: EA, EB, EC are finite sets, each carrying a
 * binary operation table (a finite magma). A map between two of them
 * models a representation homomorphism when it preserves the operation
 * table: f(x * y) = f(x) * f(y). The map h is DEFINED as the composition
 * g after f. The checked assertion is the standard equational fact that
 * the composition of two homomorphisms is a homomorphism; it needs no
 * associativity or identity axioms on the tables.
 *
 * This is a statement about abstract finite magmas and maps between them.
 * It makes no claim about the actual Monster group or its representations.
 */
module representation_composition

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

-- h is, by definition, the composition of f followed by g
fact HIsComposition {
  all x: EA | Maps.h[x] = Maps.g[Maps.f[x]]
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

assert CompositionOfHomomorphismsIsHomomorphism {
  (HomF and HomG) implies HomH
}

assert HomomorphismPreservesTripleProducts {
  (HomF and HomG) implies
    (all x, y, z: EA |
      Maps.h[MA.op[MA.op[x][y]][z]] =
        MC.op[MC.op[Maps.h[x]][Maps.h[y]]][Maps.h[z]])
}

check CompositionOfHomomorphismsIsHomomorphism for 3
check HomomorphismPreservesTripleProducts for 3

-- nontrivial homomorphisms exist in scope (premise is not vacuous)
pred ShowHomomorphisms {
  HomF and HomG
  some disj x1, x2: EA | Maps.f[x1] != Maps.f[x2]
}
run ShowHomomorphisms for 3
