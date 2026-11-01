/**
 * moonshine_dependencies.als — dependency consistency over named moonshine
 * claims (valid form).
 *
 * Finite abstraction only: four named claim nodes (two J-coefficient
 * claims, a McKay decomposition claim, a graded-dimension claim) form a
 * fixed dependency chain JCoeff1 <- JCoeff2 <- McKayDecomp <- GradedDim.
 * Each claim is labeled Established or Conjecture. The consistency RULE
 * imposed as a fact is the direct form: an Established claim may not
 * depend directly on a Conjecture claim. The assertions check the
 * transitive form of the same rule over the whole dependency DAG — no
 * Established claim may rest, even indirectly, on a Conjecture claim.
 *
 * The claim names label nodes of an abstract finite DAG. No mathematical
 * content of monstrous moonshine is asserted or checked here.
 */
module moonshine_dependencies

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

-- the owner's consistency rule, direct form
fact DirectConsistency {
  all c: Claim |
    Labeling.status[c] = Established implies
      (all d: c.dependsOn | Labeling.status[d] = Established)
}

assert TransitiveConsistency {
  all c: Claim |
    Labeling.status[c] = Established implies
      (all d: c.^dependsOn | Labeling.status[d] = Established)
}

assert ConjectureNeverSupportsEstablished {
  no c, d: Claim |
    Labeling.status[c] = Established and
    Labeling.status[d] = Conjecture and
    d in c.^dependsOn
}

check TransitiveConsistency for 4
check ConjectureNeverSupportsEstablished for 4

-- a fully established chain is a consistent labeling
pred ShowAllEstablished {
  all c: Claim | Labeling.status[c] = Established
}
run ShowAllEstablished for 4

-- a mixed labeling that respects the rule also exists: the two base
-- claims established, the two derived claims still conjectural
pred ShowMixedConsistent {
  Labeling.status[JCoeff1] = Established
  Labeling.status[JCoeff2] = Established
  Labeling.status[McKayDecomp] = Conjecture
  Labeling.status[GradedDim] = Conjecture
}
run ShowMixedConsistent for 4
