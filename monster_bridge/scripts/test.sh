#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python3 src/bridge.py scan samples samples/hits.jsonl
python3 src/bridge.py xml samples/hits.jsonl samples/contracts.xml
python3 src/bridge.py validate samples/contracts.xml
python3 - <<'PY'
import xml.etree.ElementTree as ET
r=ET.parse('samples/contracts.xml').getroot()
assert len(r.findall('claim')) == 4
assert {c.get('domain') for c in r.findall('claim')} == {'moonshine','monster','lie'}
print('PASS: extraction, domains, XML, and contract validation')
PY
