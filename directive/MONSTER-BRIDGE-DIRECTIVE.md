DIRECTIVE: MONSTER-BRIDGE — Mathematical Discovery Engine

Execution agent: OpenAI Codex
Architecture: XML-first, deterministic, contract-driven
Research domains: Monstrous Moonshine, Monster Group sporadic symmetries, Lie groups, manifolds, modular forms, holographic duality
Implementation standard: Production-grade source, executable tests, verified mathematics, reproducible provenance.

1. Mission

Build and integrate a mathematical discovery engine using:

* Mathics3 / Wolfram Language for symbolic extraction and normalization.
* Curry / PAKCS for Horn-clause resolution and recursive backtracking.
* Alloy 6 for bounded counterexample generation.
* Lean 4 / Mathlib for formal verification.
* Uiua for recursive geometry and array transformations.
* AMPL-compatible optimization models with an open-source solver.
* Rust for deterministic orchestration and XML processing.

The system must ingest historical mathematical source material, extract mathematical structures, identify candidate invariants, establish dependency relationships, search for counterexamples, and produce independently verifiable results.

The target is a million-line mathematical corpus, but scalability claims require measured benchmarks.

2. Verified Environment

The following tools have been executed successfully:

Tool — Verified state
Lean 4 — 4.12.0 default; Mathlib v4.9.0 verified
Rust / Cargo — 1.99.0
GCC — 13.3.0
Java — Temurin 21.0.12.1
Alloy 6 — Headless execution successful
Uiua — 0.19.1
Mathics3 — 10.0.1

Unavailable:

* Commercial Mathematica / Wolfram Engine.
* Curry / PAKCS.
* SWI-Prolog.
* AMPL binary.
* HiGHS, CBC, and GLPK.

Do not mark unavailable software as operational.

Mathics3 is not equivalent to Mathematica. Check function compatibility before using a symbolic feature.

3. Toolchain Recovery

Curry

Install SWI-Prolog and a compatible PAKCS distribution.

Verify:

1. Compiler/interpreter startup.
2. Logic variables and unification.
3. Recursive Horn-clause resolution.
4. Nondeterministic alternatives.
5. Recursive backtracking.
6. Occurs-check behavior where applicable.
7. Cyclic-goal handling and bounded search.

Record exact versions and executed commands.

Optimization

Install HiGHS as the initial open-source optimization backend.

Implement a native optimization model with explicit constraints, objective functions, and solver-status reporting.

Maintain an AMPL-compatible model as a separate artifact.

Do not claim AMPL execution unless the actual AMPL runtime is installed and tested.

Mathematica

Use Mathics3 for supported Wolfram Language operations.

Unsupported operations must produce explicit capability failures, not silent substitutions.

Do not require commercial Mathematica for the initial pipeline.

4. XML Mathematical Representation

Define a versioned XML schema containing:

* Source document and author.
* Publication date and provenance.
* Original mathematical expression.
* Normalized expression.
* Mathematical domain.
* Operator signatures.
* Assumptions and variable scopes.
* Candidate invariants.
* Dependency edges.
* Counterexample evidence.
* Formal proof references.
* Numerical residuals.
* Toolchain versions.
* Cryptographic source hashes.

Preserve the original expression alongside the normalized representation.

Use a typed mathematical AST rather than treating XML strings as executable mathematics.

Reject malformed XML, unsupported mathematical operations, unresolved references, and dependency cycles.

5. Corpus Extraction

Implement streaming ingestion for TXT, TeX, Lean, Wolfram Language, and other explicitly supported source formats.

Use regex for lexical candidate extraction.

Use format-specific parsers for structural interpretation.

Do not evaluate untrusted source expressions during ingestion.

Maintain:

* Source offsets.
* Line numbers.
* Document hashes.
* Encoding information.
* Extraction rule identifiers.
* Normalization history.

Benchmark ingestion on at least one million lines of generated test material, clearly distinguishing synthetic data from historical documents.

Do not fabricate historical sources or theorem citations.

6. Mathematical Research Contracts

Implement separate contract families.

MON — Monster Group

* Group identity.
* Closure.
* Associativity.
* Inverses.
* Representation homomorphisms.
* Character compatibility.
* Conjugacy-class relationships.

Do not attempt explicit enumeration of the full Monster Group.

Use validated character tables, generators, and symbolic representations where available.

MOON — Monstrous Moonshine

* Modular transformation identities.
* Normalized modular J-function coefficients.
* Graded module dimensions.
* Character decompositions.
* McKay–Thompson series relationships.
* Partition-function constraints.

Distinguish established identities from conjectured or numerically observed relationships.

LIE — Lie Groups and Manifolds

* Lie bracket antisymmetry.
* Jacobi identity.
* Structure constants.
* Group-action composition.
* Tangent-space consistency.
* Equivariance.
* Coordinate transformation compatibility.

Do not conflate discrete Monster symmetries with positive-dimensional Lie groups.

GEO — Recursive Geometry

* Forward/inverse transformation consistency.
* Recursive subdivision constraints.
* Tensor shape invariants.
* Group-action equivariance.
* Numerical reconstruction error.
* Rank and dimension preservation where mathematically required.


7. Curry Recursive Search

Implement:

* Typed logical terms.
* Substitution and unification.
* Variable standardization apart.
* Horn-clause resolution.
* Recursive backtracking.
* Bounded search.
* Goal indexing.
* Cycle detection.
* Tabling or memoization where sound.
* Derivation trees.
* Provenance propagation.

Every derived claim must identify the clauses and substitutions used.

A logical derivation is only as trustworthy as its premises and inference rules.

8. Alloy Counterexample Engine

Build separate Alloy modules for:

1. Finite group actions.
2. Representation composition.
3. Moonshine dependency consistency.
4. Lie-algebra finite abstractions.
5. Recursive geometry contracts.
6. Verification-state transitions.

Use deliberate negative tests.

Verify that invalid structures produce counterexamples.

Verify that valid bounded models satisfy their assertions within declared scopes.

Record solver scope, SAT result, execution time, and counterexample instance.

Never interpret a bounded successful Alloy check as an unrestricted mathematical proof.

9. Uiua Array Engine

Target Uiua 0.19.1.

Implement:

* Recursive tensor transformations.
* Multidimensional array indexing.
* Coordinate permutations.
* Reversible transformations where mathematically valid.
* Symmetry composition residuals.
* Lie-algebra Jacobi residuals.
* Modular coefficient analysis.
* Geometric equivariance checks.

Use native Uiua glyphs and array semantics.

Validate every glyph against the installed version.

Distinguish Unicode text reversal from mathematical inversion.

No invented Uiua syntax.

10. Lean Formal Verification

Use a pinned, compatible Lean 4 and Mathlib toolchain.

Prove:

* Abstract group-action identities.
* Representation composition laws.
* Selected finite algebraic invariants.
* Soundness properties of the contract dependency model.
* Exact mathematical identities supported by available definitions.

Every theorem must compile.

No sorry, admit, unsound axioms, or fabricated proof certificates.

Distinguish proving an abstract theorem from establishing that the Monster Group satisfies its hypotheses.

11. Optimization Contracts

Use HiGHS to optimize:

* Candidate invariant selection.
* Dependency coverage.
* Verification workload allocation.
* Search-budget allocation.
* Counterexample prioritization.

Do not optimize mathematical truth using arbitrary confidence scores.

An optimization result may prioritize candidates but cannot certify a theorem.

12. Rust Orchestration

Build a deterministic Rust command-line engine.

Required commands:

monster scan
monster normalize
monster classify
monster resolve
monster contract
monster counterexample
monster verify
monster evaluate
monster report
monster doctor

Every command must:

* Accept explicit input paths.
* Produce structured machine-readable output.
* Return meaningful exit codes.
* Preserve source provenance.
* Reject unsupported inputs.
* Record toolchain versions.
* Support deterministic replay where possible.

Do not execute mathematical source text directly from untrusted documents.

13. Verification Protocol

For each subsystem:

1. Compile or load the actual implementation.
2. Run positive tests.
3. Run negative tests.
4. Verify failure behavior.
5. Record command output.
6. Record elapsed time and peak memory where measurable.
7. Hash the resulting artifacts.
8. Export an XML verification report.

Use the following statuses:

* VERIFIED
* COUNTEREXAMPLE
* UNPROVEN
* UNSUPPORTED
* EXECUTION_FAILED

Never convert UNPROVEN into VERIFIED because a numerical test passed.

14. Repository Structure

monster-engine/
├── README.md
├── directive/
├── corpus/
├── schemas/
├── wolfram/
├── curry/
├── ampl/
├── alloy/
├── lean/
├── uiua/
├── rust/
├── contracts/
├── proofs/
├── counterexamples/
├── benchmarks/
├── tests/
├── scripts/
└── reports/

Organize source code by actual responsibility.

Avoid duplicated algorithms and decorative scaffolding.

15. Execution Order

Phase 0 — Audit: Inspect the existing repository and preserve working code.

Phase 1 — Recovery: Install and test the missing open-source dependencies.

Phase 2 — XML: Establish the typed mathematical interchange schema.

Phase 3 — Corpus: Build the streaming extraction and normalization pipeline.

Phase 4 — Logic: Connect Curry's recursive Horn-clause engine.

Phase 5 — Contracts: Implement optimization and Alloy counterexample generation.

Phase 6 — Proof: Integrate Lean with exact proof obligations.

Phase 7 — Arrays: Implement Uiua numerical and geometric kernels.

Phase 8 — Integration: Connect all stages through Rust.

Phase 9 — Benchmark: Test correctness, throughput, resource consumption, and failure recovery.

16. Non-Negotiable Engineering Rules

* No placeholders.
* No fake implementations.
* No fabricated benchmarks.
* No invented mathematical identities.
* No silently skipped tests.
* No undocumented tool substitutions.
* No false proof claims.
* No generated code that merely resembles a working implementation.
* No claims that the Monster Group has been exhaustively enumerated.
* No claims that holographic duality has been established without mathematical evidence.

Implement complete, executable components incrementally. If a dependency or mathematical proof is unavailable, report the limitation explicitly and continue only with independently valid work.

Final Deliverables

Produce:

1. Integrated source repository.
2. XML schema and mathematical contract specification.
3. Verified toolchain manifest.
4. Executable tests for every implemented subsystem.
5. Alloy counterexample archive.
6. Lean proof archive.
7. Uiua array benchmark results.
8. Corpus extraction benchmark.
9. Reproducible execution instructions.
10. Detailed implementation report distinguishing verified results, bounded checks, numerical evidence, and unresolved research questions.

Begin with the existing repository audit and toolchain recovery. Do not overwrite previously verified implementations.

The final objective is a deterministic, auditable mathematical discovery engine that can mine historical mathematical knowledge, discover candidate structural relationships, and test them against formal invariants—not simply produce plausible mathematical expressions.
