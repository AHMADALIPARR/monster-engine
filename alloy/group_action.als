/**
 * group_action.als — finite group action axioms (valid form).
 *
 * Finite abstraction only: G is an abstract finite set carrying a binary
 * operation table (mul) with a distinguished identity element (e), and S is
 * an abstract finite set carrying an action table (act). The facts state
 * the group axioms for mul and the two action axioms (the identity fixes
 * every point; the action of a product is the composition of the actions).
 * The assertions restate those properties and one consequence — every
 * group element acts bijectively — and are checked in small scopes.
 *
 * This model makes no claim about the actual Monster group: G and S are
 * unnamed finite sets, not the Monster or any of its subsets.
 */
module group_action

sig G {}
sig S {}

one sig Act {
  e: one G,
  mul: G -> G -> one G,
  act: G -> S -> one S
}

fact GroupAxioms {
  -- identity
  all g: G | Act.mul[Act.e][g] = g and Act.mul[g][Act.e] = g
  -- associativity
  all a, b, c: G | Act.mul[Act.mul[a][b]][c] = Act.mul[a][Act.mul[b][c]]
  -- two-sided inverses exist
  all g: G | some h: G | Act.mul[g][h] = Act.e and Act.mul[h][g] = Act.e
}

fact ActionAxioms {
  -- the identity element fixes every point
  all s: S | Act.act[Act.e][s] = s
  -- acting by a product is composing the two actions
  all g, h: G, s: S | Act.act[Act.mul[g][h]][s] = Act.act[g][Act.act[h][s]]
}

assert IdentityFixesPoints {
  all s: S | Act.act[Act.e][s] = s
}

assert CompositionCompatible {
  all g, h: G, s: S | Act.act[Act.mul[g][h]][s] = Act.act[g][Act.act[h][s]]
}

assert EachElementActsBijectively {
  -- injective: distinct points stay distinct
  all g: G | all disj s1, s2: S | Act.act[g][s1] != Act.act[g][s2]
  -- surjective: every point is hit
  all g: G | all s: S | some s0: S | Act.act[g][s0] = s
}

check IdentityFixesPoints for 3
check CompositionCompatible for 3
check EachElementActsBijectively for 3

-- a nontrivial action exists in scope: some non-identity element moves a point
pred ShowNontrivialAction {
  some g: G - Act.e | some s: S | Act.act[g][s] != s
}
run ShowNontrivialAction for 3
