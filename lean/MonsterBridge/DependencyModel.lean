import Mathlib

/-!
# Soundness of the finite contract dependency model

This mirrors the repo's XML contract model at the level of finite data:
claims are `Nat` ids and dependencies are a finite `List` of directed
edges `(a, b)` meaning "`a` depends on `b`" (read: `a` must come after
`b` in any valid ordering, equivalently a ranking must increase along
the edge direction used here, `rank a < rank b`).

Formulation chosen (one, finished completely): acyclicity is *existence
of a rank function* — a topological ranking `rank : Nat → Nat` that
strictly increases along every listed edge (`HasTopoRank`).  From that
single hypothesis we prove, for reachability of *any* length (the
inductive `Reach` relation: one edge, or edges chained transitively):

* ranks strictly increase along any reachability chain;
* therefore there is no dependency cycle of any length: no `Reach a a`;
* in particular no self-loop (a length-1 cycle) and no 2-cycle;
* contrapositive-usable forms: a self-loop, or a 2-cycle, in the edge
  list implies that *no* topological ranking exists.

Everything is finite and (for a concrete edge list) decidable data; the
proofs use no axioms beyond Mathlib's defaults — see `#print axioms` at
the end of this file and `proofs/axioms.txt`.

These are abstract theorems about finite edge lists.  Nothing here
asserts that any particular contract corpus in this repository is
acyclic; that is a separate check on concrete data.
-/

namespace MonsterBridge
namespace DependencyModel

/-- A topological ranking of a finite edge list: a function on ids that
    strictly increases along every edge. -/
def HasTopoRank (edges : List (Nat × Nat)) (rank : Nat → Nat) : Prop :=
  ∀ e ∈ edges, rank e.1 < rank e.2

/-- Acyclicity of the finite model, in the ranking formulation: some
    ranking strictly increases along every edge. -/
def IsRankedAcyclic (edges : List (Nat × Nat)) : Prop :=
  ∃ rank : Nat → Nat, HasTopoRank edges rank

/-- Reachability along the edge list: a dependency path of any positive
    length, built from single edges and transitivity. -/
inductive Reach (edges : List (Nat × Nat)) : Nat → Nat → Prop where
  /-- A single listed edge is a path of length 1. -/
  | step {a b : Nat} (h : (a, b) ∈ edges) : Reach edges a b
  /-- Paths compose transitively. -/
  | trans {a b c : Nat} (h₁ : Reach edges a b) (h₂ : Reach edges b c) :
      Reach edges a c

/-- Ranks strictly increase along any reachability path, of any length.
    Proof is induction on the path: one step is the ranking hypothesis,
    a composite path uses transitivity of `<` on `Nat`. -/
theorem rank_strict_of_reach {edges : List (Nat × Nat)} {rank : Nat → Nat}
    (hrank : HasTopoRank edges rank) {a b : Nat} (h : Reach edges a b) :
    rank a < rank b := by
  induction h with
  | step h => exact hrank _ h
  | trans _ _ ih₁ ih₂ => exact Nat.lt_trans ih₁ ih₂

/-- Headline theorem: under a topological ranking there is no dependency
    cycle of any length — no path from an id back to itself. -/
theorem topoRank_no_cycle {edges : List (Nat × Nat)} {rank : Nat → Nat}
    (hrank : HasTopoRank edges rank) (a : Nat) :
    ¬ Reach edges a a := by
  intro h
  have hlt := rank_strict_of_reach hrank h
  exact Nat.lt_irrefl _ hlt

/-- No self-loop: a length-1 cycle `(a, a)` cannot be an edge. -/
theorem topoRank_no_self_loop {edges : List (Nat × Nat)} {rank : Nat → Nat}
    (hrank : HasTopoRank edges rank) (a : Nat) :
    (a, a) ∉ edges := by
  intro h
  have hlt := hrank (a, a) h
  exact Nat.lt_irrefl _ hlt

/-- No 2-cycle: edges `(a, b)` and `(b, a)` cannot both be present. -/
theorem topoRank_no_two_cycle {edges : List (Nat × Nat)} {rank : Nat → Nat}
    (hrank : HasTopoRank edges rank) {a b : Nat} :
    ¬ ((a, b) ∈ edges ∧ (b, a) ∈ edges) := by
  intro h
  have hab := hrank (a, b) h.1
  have hba := hrank (b, a) h.2
  exact Nat.lt_irrefl _ (Nat.lt_trans hab hba)

/-- No 3-cycle: edges `(a, b)`, `(b, c)`, `(c, a)` cannot all be present
    (a special case of `topoRank_no_cycle`, stated concretely). -/
theorem topoRank_no_three_cycle {edges : List (Nat × Nat)} {rank : Nat → Nat}
    (hrank : HasTopoRank edges rank) {a b c : Nat} :
    ¬ ((a, b) ∈ edges ∧ (b, c) ∈ edges ∧ (c, a) ∈ edges) := by
  intro h
  exact topoRank_no_cycle hrank a
    ((Reach.step h.1).trans ((Reach.step h.2.1).trans (Reach.step h.2.2)))

/-- Contrapositive-usable form: if the edge list contains a self-loop,
    then no topological ranking of it exists. -/
theorem no_topoRank_of_self_loop {edges : List (Nat × Nat)} {a : Nat}
    (h : (a, a) ∈ edges) :
    ¬ ∃ rank : Nat → Nat, HasTopoRank edges rank := by
  rintro ⟨rank, hrank⟩
  exact topoRank_no_self_loop hrank a h

/-- Contrapositive-usable form: if the edge list contains a 2-cycle,
    then no topological ranking of it exists. -/
theorem no_topoRank_of_two_cycle {edges : List (Nat × Nat)} {a b : Nat}
    (h₁ : (a, b) ∈ edges) (h₂ : (b, a) ∈ edges) :
    ¬ ∃ rank : Nat → Nat, HasTopoRank edges rank := by
  rintro ⟨rank, hrank⟩
  exact topoRank_no_two_cycle hrank ⟨h₁, h₂⟩

/-- Contrapositive-usable form, general length: if some id reaches
    itself, then the edge list is not ranked-acyclic. -/
theorem not_rankedAcyclic_of_cycle {edges : List (Nat × Nat)} {a : Nat}
    (h : Reach edges a a) :
    ¬ IsRankedAcyclic edges := by
  rintro ⟨rank, hrank⟩
  exact topoRank_no_cycle hrank a h

/-- Sanity check on a concrete decidable instance: the empty edge list
    is ranked-acyclic (the identity ranking works vacuously), and the
    constant-zero edge case is witnessed constructively. -/
theorem empty_rankedAcyclic : IsRankedAcyclic [] :=
  ⟨id, by intro e he; simp at he⟩

/-- A concrete two-node chain `0 → 1` is ranked-acyclic, witnessed by
    the identity ranking. -/
theorem chain01_rankedAcyclic : IsRankedAcyclic [(0, 1)] :=
  ⟨id, by intro e he; simp at he; rcases he with rfl; exact Nat.zero_lt_one⟩

end DependencyModel
end MonsterBridge

#print axioms MonsterBridge.DependencyModel.topoRank_no_cycle
