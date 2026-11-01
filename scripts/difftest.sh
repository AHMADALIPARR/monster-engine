#!/usr/bin/env bash
# Differential test: monster (Rust) vs bridge.py (Python) — scan, XML, validate.
# Prints DIFFTEST PASS/FAIL with details; exit 0 on PASS, 1 on FAIL.
set -u
export PATH="$HOME/.cargo/bin:$PATH"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MONSTER="$ROOT/rust/target/debug/monster"
BRIDGE="$ROOT/monster_bridge/src/bridge.py"
SAMPLES="$ROOT/monster_bridge/samples"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FAILURES=0

note_fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }
note_ok() { echo "ok: $1"; }

if ! cargo build --manifest-path "$ROOT/rust/Cargo.toml" >"$WORK/build.log" 2>&1; then
  echo "FAIL: cargo build failed"; cat "$WORK/build.log"
  echo "DIFFTEST FAIL"
  exit 1
fi
note_ok "cargo build"

compare_jsonl() { # $1 python file, $2 rust file, $3 label
  python3 - "$1" "$2" <<'PY'
import json, sys
def load(p):
    with open(p, encoding='utf-8') as f:
        return [json.loads(line) for line in f if line.strip()]
a, b = load(sys.argv[1]), load(sys.argv[2])
if a == b:
    print(f"MATCH {len(a)} records")
    sys.exit(0)
print(f"MISMATCH python={len(a)} rust={len(b)}")
for i, (x, y) in enumerate(zip(a, b)):
    if x != y:
        print("first differing record", i)
        print(" python:", x)
        print(" rust:  ", y)
        break
sys.exit(1)
PY
}

# --- 1. samples: python scan vs rust scan -----------------------------------
python3 "$BRIDGE" scan "$SAMPLES" "$WORK/py-samples.jsonl" >/dev/null || note_fail "python scan on samples errored"
"$MONSTER" scan "$SAMPLES" "$WORK/rs-samples.jsonl" >/dev/null || note_fail "rust scan on samples errored"
if compare_jsonl "$WORK/py-samples.jsonl" "$WORK/rs-samples.jsonl" >"$WORK/cmp1.txt" 2>&1; then
  note_ok "samples scan record-for-record: $(cat "$WORK/cmp1.txt")"
else
  note_fail "samples scan mismatch: $(cat "$WORK/cmp1.txt")"
fi

# rust scan vs the shipped seed hits.jsonl (same root, so path fields
# are directly comparable; all fields including path must match)
if compare_jsonl "$ROOT/monster_bridge/samples/hits.jsonl" "$WORK/rs-samples.jsonl" >"$WORK/cmp1b.txt" 2>&1; then
  note_ok "samples scan reproduces shipped hits.jsonl exactly (all fields, path included): $(cat "$WORK/cmp1b.txt")"
else
  note_fail "shipped hits.jsonl mismatch: $(cat "$WORK/cmp1b.txt")"
fi

# --- 2. generated tricky tree -------------------------------------------------
TRICKY="$WORK/tricky"
mkdir -p "$TRICKY/a" "$TRICKY/sub"
printf 'the j invariant appears\nJ-Invariant upper\nvertex operator algebra\nmodularity of forms\nno keywords in this line\nMonster Group\nlieXalgebra\ncharacter table\nA manifold and tangent space\nhauptmodul and sporadic\nrepresentation of a Lie group\n' > "$TRICKY/a.txt"
printf 'jacobi identity\n' > "$TRICKY/b.TEX"
printf 'moonshine monster lie manifold\n' > "$TRICKY/c.md"
printf 'inner moonshine line\n' > "$TRICKY/a/inner.txt"
printf 'dash file modular\n' > "$TRICKY/a-b.txt"
printf 'nested J invariant\n' > "$TRICKY/sub/d.lean"
: > "$TRICKY/e.txt"
printf 'vertexXoperator\n' > "$TRICKY/f.wl"
python3 "$BRIDGE" scan "$TRICKY" "$WORK/py-tricky.jsonl" >/dev/null || note_fail "python scan on tricky tree errored"
"$MONSTER" scan "$TRICKY" "$WORK/rs-tricky.jsonl" >/dev/null || note_fail "rust scan on tricky tree errored"
if compare_jsonl "$WORK/py-tricky.jsonl" "$WORK/rs-tricky.jsonl" >"$WORK/cmp2.txt" 2>&1; then
  note_ok "tricky-tree scan record-for-record (wildcards, case, extensions, path ordering): $(cat "$WORK/cmp2.txt")"
else
  note_fail "tricky-tree scan mismatch: $(cat "$WORK/cmp2.txt")"
fi

# --- 3. XML export: claim counts + cross-validation ---------------------------
python3 "$BRIDGE" xml "$WORK/py-tricky.jsonl" "$WORK/py.xml" >/dev/null || note_fail "python xml export errored"
"$MONSTER" normalize "$WORK/rs-tricky.jsonl" "$WORK/rs.xml" >/dev/null || note_fail "rust normalize errored"
PYCOUNT=$(python3 -c "import xml.etree.ElementTree as ET; print(len(ET.parse('$WORK/py.xml').getroot().findall('claim')))" 2>/dev/null)
RSCOUNT=$(grep -c '<claim ' "$WORK/rs.xml" 2>/dev/null || echo 0)
if [ "$PYCOUNT" = "$RSCOUNT" ] && [ -n "$PYCOUNT" ]; then
  note_ok "XML claim counts match ($PYCOUNT claims)"
else
  note_fail "XML claim counts differ: python=$PYCOUNT rust=$RSCOUNT"
fi
if python3 "$BRIDGE" validate "$WORK/rs.xml" >/dev/null 2>&1; then
  note_ok "python validate accepts rust-produced XML"
else
  note_fail "python validate rejects rust-produced XML"
fi
if "$MONSTER" verify "$WORK/py.xml" >/dev/null 2>&1; then
  note_ok "rust verify accepts python-produced XML"
else
  note_fail "rust verify rejects python-produced XML"
fi
if "$MONSTER" verify "$WORK/rs.xml" >/dev/null 2>&1 && python3 "$BRIDGE" validate "$WORK/py.xml" >/dev/null 2>&1; then
  note_ok "both validators accept their own XML"
else
  note_fail "self-validation failed"
fi

if [ "$FAILURES" -eq 0 ]; then
  echo "DIFFTEST PASS"
  exit 0
fi
echo "DIFFTEST FAIL ($FAILURES failing checks)"
exit 1
