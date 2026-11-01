# MONSTER-BRIDGE v0.1

A non-evaluating, streaming lexical extraction bridge for Monster Group, monstrous moonshine, and Lie geometry research.

## Commands

```bash
bash scripts/test.sh
python3 src/bridge.py scan /path/to/corpus hits.jsonl
python3 src/bridge.py xml hits.jsonl contracts.xml
python3 src/bridge.py validate contracts.xml
```

The scanner reads source files line by line and writes JSONL without holding the entire corpus in memory. XML export currently loads the selected hit records in memory; shard large exports. Unicode text is preserved. No extracted source code is executed.

## Contract rules

- Every claim has source identifier, source SHA-256, line, domain, assumptions, and status.
- Raw text is always a **candidate**, never a theorem.
- `verified` requires a formal proof evidence entry and SHA-256 artifact reference. The validator checks metadata structure, **not the validity or authenticity of a proof**.
- Bounded Alloy results must not be promoted to unrestricted proofs.
- Numerical Uiua and AMPL results are not formal proof certificates.

## Planned integration adapters

- Mathematica: emit normalized expressions plus explicit assumptions and source IDs.
- Curry: read predicate records; emit derivation DAGs and fresh-variable-safe substitutions.
- AMPL: consume explicit, independently justified coverage matrices.
- Alloy: consume finite relational abstractions; emit counterexample witnesses and scopes.
- Lean: independently check mathematical claims; produce proof artifacts and hashes.
- Uiua: consume typed tensor payloads and emit residual arrays with numeric precision metadata.

The adapters above are interface targets, **not implemented or tested here**. The current implementation is the ingestion and interchange foundation. The XSD is supplied for external schema validators; the stdlib validator performs additional semantic checks.
