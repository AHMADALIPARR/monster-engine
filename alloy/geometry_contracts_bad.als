/**
 * geometry_contracts_bad.als — NEGATIVE variant of geometry_contracts.als
 * (subdivision part).
 *
 * Same finite abstraction (finite forest of cells, integer measures,
 * leaves measured 1..3; no geometric or Monster-group claim), but BROKEN:
 * the subdivision sum rule is not imposed. Internal cells carry arbitrary
 * measures, so a cell can claim measure 3 over two children of measure 1
 * each — the children do not sum to the parent.
 *
 * Expected behaviour: the ChildrenSumToParent check FINDS a
 * counterexample (result SAT), and the BadSubdivision run exhibits one.
 */
module geometry_contracts_bad

sig Cell {
  children: set Cell,
  measure: one Int
}

fact TreeShape {
  no c: Cell | c in c.^children
  all disj p1, p2: Cell | no (p1.children & p2.children)
  all c: Cell | some c.children implies #c.children >= 2
}

fact LeafMeasures {
  all c: Cell | no c.children implies (c.measure >= 1 and c.measure <= 3)
}

-- BROKEN: no fact ties an internal cell's measure to its children's
-- measures. The sum rule appears only in the assertion below.

assert ChildrenSumToParent {
  all c: Cell |
    some c.children implies c.measure = (sum ch: c.children | ch.measure)
}

-- EXPECTED: SAT (a subdivision whose children do not sum to the parent)
check ChildrenSumToParent for 4 but 6 Int

pred BadSubdivision {
  some c: Cell |
    some c.children and c.measure != (sum ch: c.children | ch.measure)
}
run BadSubdivision for 4 but 6 Int
