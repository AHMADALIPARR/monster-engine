/**
 * verification_states.als — claim-status state machine (valid form).
 *
 * Finite abstraction only: a trace is a finite sequence of states
 * (util/ordering over State). Each state carries a claim status —
 * Candidate, Bounded, Verified, or Rejected — and optionally a formal-
 * proof evidence record (the evidence field; a state either carries one
 * Proof record or none).
 *
 * The legal step relation (AllowedStep) permits staying in place,
 * progressing Candidate -> Bounded -> Verified, and moving to Rejected
 * from anywhere; Rejected is absorbing and Verified never regresses.
 * The owner's rule is imposed as a fact on every entered (non-initial)
 * state: a state whose status is Verified must carry formal-proof
 * evidence. (The initial state is Candidate, so every Verified state is
 * an entered state and the rule covers all of them.)
 *
 * The assertions check the owner's rule over the whole trace and two
 * consequences of the step relation. This is an abstract status machine
 * for contract claims; it makes no claim about the Monster group.
 */
module verification_states

open util/ordering[State]

abstract sig Status {}
one sig Candidate extends Status {}
one sig Bounded extends Status {}
one sig Verified extends Status {}
one sig Rejected extends Status {}

-- a formal-proof evidence record
sig Proof {}

sig State {
  status: one Status,
  evidence: lone Proof
}

pred AllowedStep[a, b: Status] {
  (a = Candidate and
    (b = Candidate or b = Bounded or b = Verified or b = Rejected)) or
  (a = Bounded and
    (b = Bounded or b = Verified or b = Rejected)) or
  (a = Verified and
    (b = Verified or b = Rejected)) or
  (a = Rejected and b = Rejected)
}

fact InitialState {
  first.status = Candidate
}

fact LegalTrace {
  all s: State - last | AllowedStep[s.status, s.next.status]
  -- owner's rule: entering Verified requires formal-proof evidence,
  -- carried by the Verified state itself
  all s: State - first |
    s.status = Verified implies some s.evidence
}

assert VerifiedAlwaysCarriesEvidence {
  all s: State | s.status = Verified implies some s.evidence
}

assert RejectedIsAbsorbing {
  all s: State - last |
    s.status = Rejected implies s.next.status = Rejected
}

assert VerifiedNeverRegresses {
  all s: State - last |
    s.status = Verified implies
      (s.next.status = Verified or s.next.status = Rejected)
}

check VerifiedAlwaysCarriesEvidence for 4
check RejectedIsAbsorbing for 4
check VerifiedNeverRegresses for 4

-- a trace that reaches Verified, carrying its proof evidence
pred ShowVerifiedTrace {
  some s: State | s.status = Verified and some s.evidence
}
run ShowVerifiedTrace for 4

-- a trace that ends in Rejected
pred ShowRejectedTrace {
  last.status = Rejected
}
run ShowRejectedTrace for 4
