import Mathlib

/-!
# Abstract Lie brackets: what antisymmetry and Jacobi alone imply

We work with an abstract binary operation `bracket : L → L → L` on an
additive commutative group `L` (only the additive/negation structure of a
ring is ever used).  The Lie axioms are *hypotheses* (section variables),
not facts proved here:

* `antisymm`: `⟦x, y⟧ = -⟦y, x⟧` for all `x y`;
* `jacobi`:   `⟦x, ⟦y, z⟧⟧ + ⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧ = 0` for all `x y z`.

Derived consequences proved below:

* `⟦x, x⟧ = -⟦x, x⟧` (antisymmetry at `y = x`);
* the *honest* self-bracket statement `⟦x, x⟧ + ⟦x, x⟧ = 0`.
  Remark on characteristic 2: antisymmetry alone gives `2 • ⟦x, x⟧ = 0`,
  NOT `⟦x, x⟧ = 0`.  In characteristic 2 the equation `b + b = 0` holds for
  *every* `b`, so no argument from antisymmetry alone can conclude
  `⟦x, x⟧ = 0` there; and in a general additive group `b + b = 0` only says
  `b` is 2-torsion.  We therefore prove `⟦x, x⟧ + ⟦x, x⟧ = 0` as the main
  statement, and separately prove `⟦x, x⟧ = 0` under the extra explicit
  hypothesis that `L` has no nonzero 2-torsion (`no_two_torsion`).
* `⟦x, y⟧ + ⟦y, x⟧ = 0`;
* one Jacobi manipulation that *does* follow from the stated hypotheses:
  isolating a single term, `⟦x, ⟦y, z⟧⟧ = -(⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧)`;
* the cyclic rotation of Jacobi, and rewriting an inner bracket by
  antisymmetry.

No Leibniz / derivation rule `⟦x, ⟦y, z⟧⟧ = ⟦⟦x, y⟧, z⟧ + ⟦y, ⟦x, z⟧⟧` is
assumed, so that form is *not* stated: it does not follow from
antisymmetry + Jacobi alone without bilinearity/Leibniz hypotheses.

These are abstract theorems.  Nothing here asserts that any particular
algebra (e.g. a Monster-related algebra) carries a bracket satisfying the
hypotheses.
-/

namespace MonsterBridge
namespace LieBracket

variable {L : Type*} [AddCommGroup L]
variable (bracket : L → L → L)
variable (antisymm : ∀ x y : L, bracket x y = -bracket y x)
variable (jacobi : ∀ x y z : L,
  bracket x (bracket y z) + bracket y (bracket z x) + bracket z (bracket x y) = 0)

/-- Notation for the abstract bracket, local to this file.
    (Declared after the `bracket` variable it expands to.) -/
local notation "⟦" x ", " y "⟧" => bracket x y

/-- Antisymmetry at `y = x`: the self-bracket equals its own negation. -/
theorem bracket_self_eq_neg_self (x : L) :
    ⟦x, x⟧ = -⟦x, x⟧ :=
  antisymm x x

/-- Headline theorem (the honest form): the self-bracket plus itself is
    zero, i.e. `2 • ⟦x, x⟧ = 0`.  See the char-2 remark in the file header:
    this, not `⟦x, x⟧ = 0`, is what antisymmetry alone implies. -/
theorem bracket_self_add_self_eq_zero (x : L) :
    ⟦x, x⟧ + ⟦x, x⟧ = 0 := by
  have h := congrArg (fun t : L => t + ⟦x, x⟧) (antisymm x x)
  -- h : ⟦x, x⟧ + ⟦x, x⟧ = -⟦x, x⟧ + ⟦x, x⟧
  simpa using h

/-- Under the extra hypothesis that `L` has no nonzero 2-torsion, the
    self-bracket *is* zero.  The extra hypothesis is doing real work: it
    fails in characteristic 2. -/
theorem bracket_self_eq_zero_of_no_two_torsion
    (no_two_torsion : ∀ b : L, b + b = 0 → b = 0) (x : L) :
    ⟦x, x⟧ = 0 :=
  no_two_torsion _ (bracket_self_add_self_eq_zero bracket antisymm x)

/-- A bracket plus its swap is zero. -/
theorem bracket_add_bracket_rev_eq_zero (x y : L) :
    ⟦x, y⟧ + ⟦y, x⟧ = 0 := by
  rw [antisymm y x]
  simp

/-- Jacobi manipulation that follows from the stated hypotheses alone:
    a single Jacobi term isolated on one side. -/
theorem jacobi_single (x y z : L) :
    ⟦x, ⟦y, z⟧⟧ = -(⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧) := by
  have h := jacobi x y z
  rw [add_assoc] at h
  exact eq_neg_of_add_eq_zero_left h

/-- The cyclic rotation of the Jacobi identity (the same identity with
    the variables rotated; it is an instance, not a new assumption). -/
theorem jacobi_rot (x y z : L) :
    ⟦y, ⟦z, x⟧⟧ + ⟦z, ⟦x, y⟧⟧ + ⟦x, ⟦y, z⟧⟧ = 0 :=
  jacobi y z x

/-- Rewriting an inner bracket by antisymmetry, by congruence only
    (no linearity of the outer bracket is needed or used). -/
theorem bracket_inner_swap (x y z : L) :
    ⟦x, ⟦y, z⟧⟧ = ⟦x, -⟦z, y⟧⟧ := by
  rw [antisymm y z]

end LieBracket
end MonsterBridge

#print axioms MonsterBridge.LieBracket.bracket_self_add_self_eq_zero
