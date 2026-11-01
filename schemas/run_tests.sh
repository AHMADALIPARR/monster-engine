#!/bin/sh
# Runs validate_v2.py over the v2 examples and checks the XSD itself.
# Expectation: the valid example passes; each invalid example fails with
# its specific error class in stderr; the XSD parses as well-formed XML
# (and is checked with xmllint as well when xmllint is installed).
# Prints a tally and exits nonzero on any mismatch.

set -u
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
VALIDATOR="$DIR/validate_v2.py"
EXAMPLES="$DIR/examples"
TOTAL=0
PASSED=0

report_ok() {
    PASSED=$((PASSED + 1))
    echo "PASS: $1"
}

report_bad() {
    echo "FAIL: $1"
}

# 1. XSD well-formedness.
TOTAL=$((TOTAL + 1))
if python3 -c "import sys, xml.etree.ElementTree as ET; ET.parse(sys.argv[1])" "$DIR/contract-v2.xsd" 2>/dev/null; then
    if command -v xmllint >/dev/null 2>&1; then
        if xmllint --noout "$DIR/contract-v2.xsd" 2>/dev/null; then
            report_ok "contract-v2.xsd is well-formed XML (ElementTree and xmllint)"
        else
            report_bad "contract-v2.xsd rejected by xmllint"
        fi
    else
        report_ok "contract-v2.xsd is well-formed XML (ElementTree; xmllint not installed)"
    fi
else
    report_bad "contract-v2.xsd is not well-formed XML"
fi

# 2. The valid example must validate.
TOTAL=$((TOTAL + 1))
if python3 "$VALIDATOR" "$EXAMPLES/valid-moonshine.xml" >/dev/null 2>&1; then
    report_ok "valid-moonshine.xml validates"
else
    report_bad "valid-moonshine.xml was rejected"
    python3 "$VALIDATOR" "$EXAMPLES/valid-moonshine.xml" 2>&1 | sed 's/^/    /'
fi

# 3. Each invalid example must be rejected with its expected error class.
check_invalid() {
    file=$1
    pattern=$2
    TOTAL=$((TOTAL + 1))
    output=$(python3 "$VALIDATOR" "$EXAMPLES/$file" 2>&1)
    status=$?
    if [ $status -eq 0 ]; then
        report_bad "$file was accepted, expected rejection ($pattern)"
        return
    fi
    if printf '%s' "$output" | grep -qi "$pattern"; then
        report_ok "$file rejected with expected error class '$pattern'"
    else
        report_bad "$file rejected with the wrong error: $output"
    fi
}

check_invalid invalid-malformed.xml "malformed XML"
check_invalid invalid-unsupported-operator.xml "unsupported operator"
check_invalid invalid-unresolved-dependency.xml "unresolved dependency"
check_invalid invalid-dependency-cycle.xml "dependency cycle"
check_invalid invalid-unsubstantiated-verified.xml "unsubstantiated verified"

echo "Tally: $PASSED/$TOTAL"
if [ "$PASSED" -ne "$TOTAL" ]; then
    exit 1
fi
exit 0
