/**
 * moonshine_dependencies_bad.als — NEGATIVE variant of
 * moonshine_dependencies.als.
 *
 * Same finite abstraction (four named claim nodes in a fixed dependency
 * chain; no mathematical content of moonshine is asserted), but BROKEN:
 * an inconsistent labeling is injected — the base J-coefficient claim
 * JCoeff1 is labeled Conjecture while JCoeff2, which depends directly on
 * it, is labeled Established. The consistency rule is NOT imposed as a
 * fact in this module, so the injected instance itself is a counterexample.
 *
 * Expected behaviour: both consistency checks FIND counterexamples
 * (result SAT).
 */
module moonshine_dependencies_bad

abstract sig Claim { dependsOn: set Claim }
one sig JCoeff1 extends Claim {}
one sig JCoeff2 extends Claim {}
one sig McKayDecomp extends Claim {}
one sig GradedDim extends Claim {}

abstract sig Status {}
one sig Established extends Status {}
one sig Conjecture extends Status {}

one sig Labeling { status: Claim -> one Status }

fact DependencyChain {
  no JCoeff1.dependsOn
  JCoeff2.dependsOn = JCoeff1
  McKayDecomp.dependsOn = JCoeff2
  GradedDim.dependsOn = McKayDecomp
}

fact DependencyGraphIsAcyclic {
  no c: Claim | c in c.^dependsOn
}

-- BROKEN: the injected inconsistent labeling. An Established claim
-- (JCoeff2) rests directly on a Conjecture claim (JCoeff1), and no
-- consistency fact forbids it in this module.
fact InjectedInconsistentLabeling {
  Labeling.status[JCoeff1] = Conjecture
  Labeling.status[JCoeff2] = Established
}

assert DirectConsistency {
  all c: Claim |
    Labeling.status[c] = Established implies
      (all d: c.dependsOn | Labeling.status[d] = Established)
}

assert TransitiveConsistency {
  all c: Claim |
    Labeling.status[c] = Established implies
      (all d: c.^dependsOn | Labeling.status[d] = Established)
}

-- EXPECTED: SAT (the injected labeling is a counterexample)
check DirectConsistency for 4
-- EXPECTED: SAT (the same labeling violates the transitive rule too)
check TransitiveConsistency for 4

pred InconsistentLabeling {
  Labeling.status[JCoeff2] = Established
  Labeling.status[JCoeff1] = Conjecture
  JCoeff1 in JCoeff2.dependsOn
}
run InconsistentLabeling for 4
