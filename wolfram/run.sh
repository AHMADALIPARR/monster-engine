#!/bin/sh
# run.sh -- run the Mathics3 / Wolfram subsystem scripts and capture outputs.
# Usage: sh wolfram/run.sh   (or ./wolfram/run.sh)
# Outputs go to wolfram/outputs/:
#   normalize.out, capabilities.out, version.txt
# Exits nonzero if either script exits nonzero, or if normalize.wl's
# expected True lines are absent from its captured output.
set -u

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT_DIR="$SCRIPT_DIR/outputs"
MATHICS="${MATHICS:-$HOME/workspace/.tools/mathics-venv/bin/mathics}"

mkdir -p "$OUT_DIR"

if [ ! -x "$MATHICS" ]; then
  echo "run.sh: Mathics executable not found at $MATHICS" >&2
  exit 1
fi

# Version string exactly as printed by the tool.
"$MATHICS" --version > "$OUT_DIR/version.txt" 2>&1 || true
cat "$OUT_DIR/version.txt"

echo "run.sh: running normalize.wl ..."
timeout 180 "$MATHICS" -f "$SCRIPT_DIR/normalize.wl" > "$OUT_DIR/normalize.out" 2>&1
norm_status=$?
cat "$OUT_DIR/normalize.out"
echo "run.sh: normalize.wl exit status: $norm_status"

echo "run.sh: running capabilities.wl ..."
timeout 180 "$MATHICS" -f "$SCRIPT_DIR/capabilities.wl" > "$OUT_DIR/capabilities.out" 2>&1
cap_status=$?
cat "$OUT_DIR/capabilities.out"
echo "run.sh: capabilities.wl exit status: $cap_status"

fail=0
if [ "$norm_status" -ne 0 ]; then
  echo "run.sh: FAIL - normalize.wl exited nonzero ($norm_status)" >&2
  fail=1
fi
if [ "$cap_status" -ne 0 ]; then
  echo "run.sh: FAIL - capabilities.wl exited nonzero ($cap_status)" >&2
  fail=1
fi

# Expected True lines in normalize output. Absence is a failure,
# even if the script somehow exited 0.
for expected in \
  "Identity check 1: Expand[(x + y)^2] == x^2 + 2 x y + y^2 : True" \
  "Identity check 2: Factor[x^2 - 1] == (x - 1) (x + 1) : True" \
  "Identity check 2b: Expand[(x - 1) (x + 1)] == x^2 - 1 : True" \
  "Coefficient check: Coefficient[jPoly, q, 1] == 196884 : True" \
  "McKay verification: 196884 - 196883 == 1 : True"
do
  if ! grep -Fq "$expected" "$OUT_DIR/normalize.out"; then
    echo "run.sh: FAIL - expected line absent from normalize.out: $expected" >&2
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "run.sh: PASS - both scripts ran and all expected True lines are present."
exit 0
