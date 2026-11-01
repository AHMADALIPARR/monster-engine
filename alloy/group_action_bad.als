/**
 * group_action_bad.als — NEGATIVE variant of group_action.als.
 *
 * Same finite abstraction (abstract finite G, S, operation and action
 * tables; no claim about the actual Monster group), but the action is
 * BROKEN: the group axioms and the identity axiom are kept, while the
 * composition axiom is deliberately omitted. Such an "action" need not
 * respect composition — for example a generator of a 3-element group can
 * act as a transposition (order 2) while its square acts as the identity.
 *
 * Expected behaviour: the CompositionCompatible check FINDS a
 * counterexample (result SAT), while the IdentityFixesPoints check still
 * finds none (result UNSAT), because the identity axiom is retained.
 */
module group_action_bad

sig G {}
sig S {}

one sig Act {
  e: one G,
  mul: G -> G -> one G,
  act: G -> S -> one S
}

fact GroupAxioms {
  all g: G | Act.mul[Act.e][g] = g and Act.mul[g][Act.e] = g
  all a, b, c: G | Act.mul[Act.mul[a][b]][c] = Act.mul[a][Act.mul[b][c]]
  all g: G | some h: G | Act.mul[g][h] = Act.e and Act.mul[h][g] = Act.e
}

fact IdentityAxiomOnly {
  all s: S | Act.act[Act.e][s] = s
  -- BROKEN: no composition axiom is imposed on act.
}

assert IdentityFixesPoints {
  all s: S | Act.act[Act.e][s] = s
}

assert CompositionCompatible {
  all g, h: G, s: S | Act.act[Act.mul[g][h]][s] = Act.act[g][Act.act[h][s]]
}

check IdentityFixesPoints for 3
-- EXPECTED: SAT (a counterexample action exists within scope)
check CompositionCompatible for 3

-- exhibits one concrete broken action: a triple (g, h, s) where acting by
-- the product mul[g][h] differs from composing the two actions
pred BrokenAction {
  some g, h: G, s: S | Act.act[Act.mul[g][h]][s] != Act.act[g][Act.act[h][s]]
}
run BrokenAction for 3
