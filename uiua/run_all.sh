#!/usr/bin/env bash
# Run every Uiua kernel in this directory, capture stdout to outputs/,
# then cross-check the printed numbers with check.py.
#
# Canonical invocation per file (Uiua 0.19.1):
#   ~/workspace/.tools/uiua/uiua run <file>.ua
# The runner adds --no-format (do not rewrite the source files while
# running them) and --no-color (plain text for the checker). Any final
# stack values a program leaves are printed by `uiua run` to stderr;
# these programs print all results explicitly with &p to stdout and
# leave the stack empty, and stderr is captured alongside for the
# record.
set -u
cd "$(dirname "$0")"
UIUA="$HOME/workspace/.tools/uiua/uiua"
mkdir -p outputs

status=0
for name in jacobi jcoeff transforms equivariance; do
    "$UIUA" run --no-format --no-color "$name.ua" \
        > "outputs/$name.txt" 2> "outputs/$name.stderr.txt"
    rc=$?
    echo "$name.ua: exit $rc"
    if [ "$rc" -ne 0 ]; then
        status=1
    fi
done

python3 check.py
if [ "$?" -ne 0 ]; then
    status=1
fi
exit "$status"
