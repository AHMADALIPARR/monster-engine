#!/usr/bin/env python3
"""Streaming, non-evaluating mathematical corpus extractor.

This extends the seed scanner in ``monster_bridge/src/bridge.py`` without
modifying it.  Semantics shared with the seed's ``scan()``:

* Same record fields, in the same order: ``id``, ``source``, ``path``,
  ``sha256``, ``line``, ``domain``, ``expression``, ``status``.
* Same extension set: .txt, .tex, .wl, .m, .lean, .als, .curry.
* Same traversal: files under the root are visited in sorted path order
  and numbered ``s1``, ``s2``, ... in that order; the per-file SHA-256 is
  computed over the raw bytes in 1 MiB blocks exactly as the seed's
  ``digest()`` does.
* Same record granularity: at most one record per (line, domain) hit,
  domains tested in declaration order, records numbered ``c1``, ``c2``,
  ... in scan order, every record's ``status`` is ``candidate``, and a
  ``--max-hits`` cap (default 1000000, as in the seed) stops the scan.
* The three seed domains (moonshine, monster, lie) keep the seed's
  regexes verbatim.  Each seed pattern is a single alternation; here each
  alternation branch becomes a numbered sub-pattern of the same family,
  so the family matches a line exactly when the seed's combined regex
  does, and the branch that matched first (in alternation order) is
  reported as the extraction rule.

Additional contract families (directive section 6):

* ``geometry`` (GEO -- recursive geometry): recursive subdivision,
  tensor, equivariance, equivariant, coordinate transformation.
* ``modular`` (MOON -- modular forms): modular form, q-expansion,
  McKay-Thompson, hauptmodul.  Overlap with ``moonshine`` is expected:
  a line containing "modular form" also matches the moonshine family's
  ``modular`` branch, and "hauptmodul" is a branch of both families, so
  such a line yields one record per family, exactly as overlapping seed
  families do.

Additional fields appended to every record:

* ``rule``: extraction rule identifier, ``"<family>:<index>"`` where the
  index is the 0-based position of the matching sub-pattern in the
  family's list below.
* ``offset``: byte offset of the start of the line within its file.
* ``encoding``: the encoding used to decode the file, always the
  constant string ``"utf-8"``; decoding uses UTF-8 with replacement of
  undecodable bytes (``errors="replace"``), as in the seed.

Rule index map (family -> index: sub-pattern):

* moonshine: 0 moonshine, 1 hauptmodul, 2 vertex.operator, 3 modular,
  4 j.invariant
* monster: 0 monster.group, 1 sporadic, 2 character.table,
  3 representation
* lie: 0 lie.algebra, 1 lie.group, 2 jacobi.identity, 3 tangent.space,
  4 manifold
* geometry: 0 recursive.subdivision, 1 tensor, 2 equivariance,
  3 equivariant, 4 coordinate.transformation
* modular: 0 modular.form, 1 q.expansion, 2 mckay.thompson, 3 hauptmodul

Streaming guarantee: files are read one line at a time in binary mode
(each raw line is decoded individually), records are written as they are
found, and the only accumulated state is counters.  Neither a whole file
nor the whole hit set is ever held in memory.  File contents are never
evaluated or executed; extraction is purely lexical.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path

# The first three families reproduce the seed PATTERNS regexes in
# monster_bridge/src/bridge.py branch by branch, in the seed's order:
#   moonshine: r'(?i)moonshine|hauptmodul|vertex.operator|modular|j.invariant'
#   monster:   r'(?i)monster.group|sporadic|character.table|representation'
#   lie:       r'(?i)lie.algebra|lie.group|jacobi.identity|tangent.space|manifold'
# Each branch is compiled with the same (?i) flag the seed applies to the
# whole alternation, so family-level matching is identical to the seed's.
import re

FAMILIES = [
    ("moonshine", [
        r"moonshine",
        r"hauptmodul",
        r"vertex.operator",
        r"modular",
        r"j.invariant",
    ]),
    ("monster", [
        r"monster.group",
        r"sporadic",
        r"character.table",
        r"representation",
    ]),
    ("lie", [
        r"lie.algebra",
        r"lie.group",
        r"jacobi.identity",
        r"tangent.space",
        r"manifold",
    ]),
    ("geometry", [
        r"recursive.subdivision",
        r"tensor",
        r"equivariance",
        r"equivariant",
        r"coordinate.transformation",
    ]),
    ("modular", [
        r"modular.form",
        r"q.expansion",
        r"mckay.thompson",
        r"hauptmodul",
    ]),
]

PATTERNS = [
    (name,
     [re.compile(branch, re.IGNORECASE) for branch in branches],
     re.compile('(?:' + '|'.join(branches) + ')', re.IGNORECASE))
    for name, branches in FAMILIES
]

EXTENSIONS = {'.txt', '.tex', '.wl', '.m', '.lean', '.als', '.curry'}
ENCODING = 'utf-8'


def digest(path):
    """SHA-256 over raw file bytes, identical to the seed's digest()."""
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def first_matching_rule(branches, line):
    """Return the index of the first sub-pattern matching line, or None."""
    for index, regex in enumerate(branches):
        if regex.search(line):
            return index
    return None


def matching_rule(branches, combined, line):
    """Return the family's rule index for line, or None if it does not hit.

    The combined pattern is the alternation of the family's sub-patterns,
    so it matches exactly when at least one sub-pattern does; the
    per-branch scan then runs only on hit lines to identify the first
    matching branch, in list order, as the extraction rule.
    """
    if not combined.search(line):
        return None
    return first_matching_rule(branches, line)


def scan(root, out, max_hits):
    """Stream-scan root, writing one JSON record per (line, domain) hit.

    Returns the number of records written.  Mirrors the seed's scan():
    sorted file order, per-file source ids, per-file SHA-256, candidate
    status, and the max_hits cap checked before each record is written.
    """
    root = root.resolve()
    paths = sorted(p for p in root.rglob('*') if p.is_file() and p.suffix.lower() in EXTENSIONS)
    count = 0
    with out.open('w', encoding='utf-8') as dest:
        for idx, path in enumerate(paths):
            source = f's{idx + 1}'
            checksum = digest(path)
            relative = str(path.relative_to(root))
            offset = 0
            with path.open('rb') as f:
                for lineno, raw in enumerate(f, 1):
                    line_offset = offset
                    offset += len(raw)
                    line = raw.decode(ENCODING, errors='replace')
                    expression = line.rstrip('\n')
                    if expression.endswith('\r'):
                        expression = expression[:-1]
                    for domain, branches, combined in PATTERNS:
                        rule_index = matching_rule(branches, combined, line)
                        if rule_index is None:
                            continue
                        if count >= max_hits:
                            return count
                        count += 1
                        record = {'id': f'c{count}', 'source': source, 'path': relative,
                                  'sha256': checksum, 'line': lineno, 'domain': domain,
                                  'expression': expression, 'status': 'candidate',
                                  'rule': f'{domain}:{rule_index}', 'offset': line_offset,
                                  'encoding': ENCODING}
                        dest.write(json.dumps(record, ensure_ascii=False) + '\n')
    return count


def main():
    p = argparse.ArgumentParser(description='Streaming corpus extractor (seed-compatible, extended families)')
    p.add_argument('root', type=Path)
    p.add_argument('output', type=Path)
    p.add_argument('--max-hits', type=int, default=1000000)
    args = p.parse_args()
    try:
        result = scan(args.root, args.output, args.max_hits)
    except OSError as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)
    print(f'scan: {result} records')


if __name__ == '__main__':
    main()
