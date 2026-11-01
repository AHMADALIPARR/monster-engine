#!/bin/bash
# Phase 4 -- Curry dependency resolution: generate the facts from
# contracts/families.json, run Resolve.curry under PAKCS (REPL batch
# mode, the invocation pattern of the Phase 1 battery), capture the
# raw session to outputs/, and verify the printed sets against the
# independent Python checker.
set -euo pipefail
cd "$(dirname "$0")"

export PATH="$HOME/workspace/.tools/pakcs-3.9.0/bin:$PATH"
export LC_ALL=C.UTF-8

mkdir -p outputs

python3 gen_facts.py

printf ":load Resolve\nmain\n:quit\n" | pakcs > outputs/resolve-output.txt 2>&1

python3 check.py outputs/resolve-output.txt | tee outputs/check-output.txt

echo "run.sh: done; raw Curry session in outputs/resolve-output.txt, comparison in outputs/check-output.txt"
