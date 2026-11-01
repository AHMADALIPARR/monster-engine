#!/usr/bin/env python3
"""Streaming, non-evaluating mathematical corpus scanner and contract validator."""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

PATTERNS = {
    'moonshine': re.compile(r'(?i)moonshine|hauptmodul|vertex.operator|modular|j.invariant'),
    'monster': re.compile(r'(?i)monster.group|sporadic|character.table|representation'),
    'lie': re.compile(r'(?i)lie.algebra|lie.group|jacobi.identity|tangent.space|manifold'),
}
EXTENSIONS = {'.txt', '.tex', '.wl', '.m', '.lean', '.als', '.curry'}
ALLOWED_STATUSES = {'candidate', 'rejected', 'bounded', 'verified'}


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def scan(root, out, max_hits):
    root = root.resolve()
    paths = sorted(p for p in root.rglob('*') if p.is_file() and p.suffix.lower() in EXTENSIONS)
    count = 0
    with out.open('w', encoding='utf-8') as dest:
        for idx, path in enumerate(paths):
            source = f's{idx + 1}'
            checksum = digest(path)
            with path.open('r', encoding='utf-8', errors='replace') as f:
                for lineno, line in enumerate(f, 1):
                    domains = [name for name, regex in PATTERNS.items() if regex.search(line)]
                    for domain in domains:
                        if count >= max_hits:
                            return count
                        count += 1
                        record = {'id': f'c{count}', 'source': source, 'path': str(path.relative_to(root)),
                                  'sha256': checksum, 'line': lineno, 'domain': domain,
                                  'expression': line.rstrip('\n'), 'status': 'candidate'}
                        dest.write(json.dumps(record, ensure_ascii=False) + '\n')
    return count


def export(records, output):
    root = ET.Element('research', version='1')
    seen = {}
    claims = []
    with records.open(encoding='utf-8') as f:
        for line in f:
            r = json.loads(line)
            key = r['source']
            if key in seen and seen[key] != (r['path'], r['sha256']):
                raise ValueError('source identifier collision')
            seen[key] = (r['path'], r['sha256'])
            claims.append(r)
    for sid, (path, checksum) in seen.items():
        ET.SubElement(root, 'source', id=sid, path=path, sha256=checksum)
    for r in claims:
        node = ET.SubElement(root, 'claim', id=r['id'], source=r['source'],
                             line=str(r['line']), domain=r['domain'], status='candidate')
        ET.SubElement(node, 'expression').text = r['expression']
        ET.SubElement(node, 'assumptions').text = 'Uninterpreted extracted text; not a proven formula'
    ET.indent(root)
    ET.ElementTree(root).write(output, encoding='utf-8', xml_declaration=True)
    return len(claims)


def validate(path):
    tree = ET.parse(path)
    root = tree.getroot()
    if root.tag != 'research' or root.get('version') != '1':
        raise ValueError('invalid root or schema version')
    sources = {s.get('id') for s in root.findall('source')}
    claims = root.findall('claim')
    ids = [c.get('id') for c in claims]
    if len(ids) != len(set(ids)) or not all(ids):
        raise ValueError('duplicate or missing claim identifiers')
    for c in claims:
        if c.get('source') not in sources:
            raise ValueError(f"unknown source: {c.get('id')}")
        if c.get('status') not in ALLOWED_STATUSES:
            raise ValueError(f"invalid status: {c.get('id')}")
        if not c.findtext('expression') or not c.findtext('assumptions'):
            raise ValueError(f"missing expression/assumptions: {c.get('id')}")
        for d in c.findall('dependency'):
            if d.get('ref') not in ids:
                raise ValueError(f"missing dependency: {c.get('id')}")
        if c.get('status') == 'verified' and not any(
            e.get('tool') in {'lean', 'coq', 'agda', 'isabelle'} and
            e.get('status') == 'verified' and
            re.fullmatch('[0-9a-f]{64}', e.get('artifact_sha256', ''))
            for e in c.findall('evidence')):
            raise ValueError(f"unsubstantiated verified status: {c.get('id')}")
    return len(claims)


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd', required=True)
    a = sub.add_parser('scan'); a.add_argument('root', type=Path); a.add_argument('output', type=Path)
    a.add_argument('--max-hits', type=int, default=1000000)
    a = sub.add_parser('xml'); a.add_argument('records', type=Path); a.add_argument('output', type=Path)
    a = sub.add_parser('validate'); a.add_argument('xmlfile', type=Path)
    args = p.parse_args()
    try:
        if args.cmd == 'scan': result = scan(args.root, args.output, args.max_hits)
        elif args.cmd == 'xml': result = export(args.records, args.output)
        else: result = validate(args.xmlfile)
        print(f'{args.cmd}: {result} records')
    except (OSError, ValueError, ET.ParseError, json.JSONDecodeError) as exc:
        print(f'ERROR: {exc}', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
