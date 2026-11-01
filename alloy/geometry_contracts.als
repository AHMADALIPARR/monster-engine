/**
 * geometry_contracts.als — recursive subdivision and transform contracts
 * (valid form).
 *
 * Finite abstraction only, in two independent parts:
 *
 * (1) Recursive subdivision. Cells form a finite forest (each cell has at
 * most one parent, and the children relation is acyclic). A leaf carries
 * an abstract measure (an integer in 1..3). The subdivision RULE, imposed
 * as a fact, is that every internal cell's measure equals the sum of its
 * children's measures. The assertions check two consequences of that
 * rule: the two-level unfolding (a grandparent's measure equals the sum
 * of its grandchildren's measures) and global conservation (a root's
 * measure equals the sum of the measures of all leaves beneath it).
 *
 * (2) Forward / inverse transforms. A transform on a finite coordinate
 * set is given by a pair of functions fwd and inv tied together by the
 * fact that inv[y] is the unique x with fwd[x] = y. The assertion checks
 * both round trips: inv after fwd and fwd after inv are the identity.
 *
 * Measures and coordinates are abstract finite data; no geometric or
 * Monster-group claim is made.
 */
module geometry_contracts

sig Cell {
  children: set Cell,
  measure: one Int
}

sig Coord {}

one sig Tr {
  fwd: Coord -> one Coord,
  inv: Coord -> one Coord
}

fact TreeShape {
  -- acyclic: no cell is its own descendant
  no c: Cell | c in c.^children
  -- at most one parent per cell
  all disj p1, p2: Cell | no (p1.children & p2.children)
  -- a subdivision step splits a cell into at least two children
  all c: Cell | some c.children implies #c.children >= 2
}

fact LeafMeasures {
  all c: Cell | no c.children implies (c.measure >= 1 and c.measure <= 3)
}

-- the subdivision rule: a parent's measure is the sum of its children's
fact SubdivisionSumRule {
  all c: Cell |
    some c.children implies c.measure = (sum ch: c.children | ch.measure)
}

-- inv is defined as the inverse relation of fwd
fact InverseDefinition {
  all x, y: Coord | Tr.fwd[x] = y iff Tr.inv[y] = x
}

assert TwoLevelSum {
  all c: Cell |
    (some c.children and (all ch: c.children | some ch.children)) implies
      c.measure = (sum g: c.children.children | g.measure)
}

assert RootMeasureEqualsLeafTotal {
  all r: Cell |
    (no p: Cell | r in p.children) implies
      r.measure =
        (sum l: {l: Cell | no l.children and l in (r + r.^children)} |
           l.measure)
}

assert TransformRoundTrips {
  all x: Coord | Tr.inv[Tr.fwd[x]] = x
  all y: Coord | Tr.fwd[Tr.inv[y]] = y
}

check TwoLevelSum for 5 but 6 Int
check RootMeasureEqualsLeafTotal for 5 but 6 Int
check TransformRoundTrips for 5 but 6 Int

pred ShowSubdivision {
  some c: Cell | #c.children >= 2
  some c: Cell | some c.children.children
}
run ShowSubdivision for 5 but 6 Int

pred ShowNontrivialTransform {
  some x: Coord | Tr.fwd[x] != x
}
run ShowNontrivialTransform for 5 but 6 Int
