/**
 * verification_states_bad.als — NEGATIVE variant of
 * verification_states.als.
 *
 * Same finite abstraction (ordered trace of states with statuses
 * Candidate / Bounded / Verified / Rejected and optional formal-proof
 * evidence records; no claim about the Monster group), and the same
 * AllowedStep relation — but BROKEN: the owner's evidence rule is not
 * imposed. Traces may step Candidate -> Verified with no proof evidence
 * anywhere in the trace.
 *
 * Expected behaviour: the VerifiedAlwaysCarriesEvidence check FINDS a
 * counterexample (result SAT) — a trace reaching Verified without
 * evidence — while RejectedIsAbsorbing still finds none (result UNSAT),
 * because the step relation itself is intact.
 */
module verification_states_bad

open util/ordering[State]

abstract sig Status {}
one sig Candidate extends Status {}
one sig Bounded extends Status {}
one sig Verified extends Status {}
one sig Rejected extends Status {}

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

fact LegalTraceStepsOnly {
  all s: State - last | AllowedStep[s.status, s.next.status]
  -- BROKEN: no evidence requirement is imposed on Verified states.
}

assert VerifiedAlwaysCarriesEvidence {
  all s: State | s.status = Verified implies some s.evidence
}

assert RejectedIsAbsorbing {
  all s: State - last |
    s.status = Rejected implies s.next.status = Rejected
}

-- EXPECTED: SAT (a trace reaches Verified without evidence)
check VerifiedAlwaysCarriesEvidence for 4
check RejectedIsAbsorbing for 4

-- exhibits one offending trace explicitly
pred VerifiedWithoutEvidence {
  some s: State | s.status = Verified and no s.evidence
}
run VerifiedWithoutEvidence for 4
