#!/usr/bin/env python3
"""Validator for Monster-Bridge contract documents, schema version 2.

Python 3 standard library only. Enforces, in order:

  1. XML well-formedness (malformed input is rejected at parse time).
  2. Structural conformance with schemas/contract-v2.xsd for the elements
     and attributes defined there (required elements, element order at the
     levels the schema fixes, enumerations, sha256 patterns, date and
     numeric literal shapes).
  3. Semantic rules mirroring and extending the v1 validator in
     monster_bridge/src/bridge.py:
       - unique claim identifiers and unique source identifiers;
       - every claim references a declared source;
       - dependency references resolve to declared claims;
       - the dependency graph is acyclic (new in v2; v1 did not check);
       - status "verified" requires formal-proof evidence: an evidence
         entry or a formal-proof-reference whose tool is one of
         lean / coq / agda / isabelle, whose status is "verified", and
         whose artifact hash is a 64-digit lowercase hex sha256
         (the v1 rule, applied to both v2 evidence forms);
       - every operator used in a normalized expression is in the global
         operator registry, is used at the registry arity, and is declared
         in the claim's operator signatures (unsupported or unregistered
         operators are rejected);
       - every symbol used in a normalized expression is declared in the
         claim's variable scopes, or bound by an enclosing binder.

Exit codes: 0 when the document is valid, 1 when it is invalid, with one
specific error message on stderr.
"""

import re
import sys
import xml.etree.ElementTree as ET
from datetime import date

SHA256_RE = re.compile(r"[0-9a-f]{64}")
NUMERIC_RE = re.compile(r"-?[0-9]+(\.[0-9]+)?")
YEAR_RE = re.compile(r"[0-9]{4}")
FULL_DATE_RE = re.compile(r"[0-9]{4}-[0-9]{2}-[0-9]{2}")

# Global operator registry: name -> fixed arity. Mirrors OperatorNameType
# and the operator-registry element defined in contract-v2.xsd.
GLOBAL_OPERATORS = {
    "add": 2,
    "subtract": 2,
    "multiply": 2,
    "divide": 2,
    "power": 2,
    "negate": 1,
    "equals": 2,
    "not-equals": 2,
    "less-than": 2,
    "less-or-equal": 2,
    "greater-than": 2,
    "greater-or-equal": 2,
    "coefficient": 2,
}

CLAIM_STATUSES = {"candidate", "rejected", "bounded", "verified"}
REPORT_STATUSES = {"VERIFIED", "COUNTEREXAMPLE", "UNPROVEN", "UNSUPPORTED", "EXECUTION_FAILED"}
EVIDENCE_STATUSES = {"candidate", "rejected", "bounded", "verified", "counterexample"}
EVIDENCE_KINDS = {"formal-proof", "counterexample", "numerical", "computational", "source-check"}
DOMAINS = {"moonshine", "monster", "lie", "geo", "modular-forms", "general"}
PROOF_TOOLS = {"lean", "coq", "agda", "isabelle"}
BINDER_KINDS = {"sum", "product", "forall", "exists", "lambda", "limit"}
VARIABLE_KINDS = {"variable", "function", "parameter", "constant"}
BINDINGS = {"free", "bound"}
DEPENDENCY_RELATIONS = {"depends-on", "uses", "supports", "refutes"}
HASH_ROLES = {"source", "original-expression", "normalized-expression", "proof-artifact"}
NODE_TAGS = {"number", "symbol", "apply", "call", "binder"}

ROOT_CHILDREN = ["operator-registry", "source", "claim"]
SOURCE_CHILDREN = ["title", "author", "publication-date", "provenance"]
CLAIM_CHILDREN = [
    "original-expression", "normalized-expression", "operator-signatures",
    "assumptions", "variable-scopes", "candidate-invariants", "dependencies",
    "evidence", "counterexample-evidence", "formal-proof-references",
    "numerical-residuals", "toolchain-versions", "source-hashes",
    "verification-report",
]
REQUIRED_CLAIM_CHILDREN = ["original-expression", "normalized-expression", "assumptions"]


class ValidationError(Exception):
    """One specific, user-facing validation failure."""


def fail(message):
    raise ValidationError(message)


def is_sha256(value):
    return value is not None and SHA256_RE.fullmatch(value) is not None


def require_text(element, where):
    if element is None or element.text is None or not element.text.strip():
        fail(f"schema: empty or missing text in {where}")
    return element.text.strip()


def check_date(value, where):
    if YEAR_RE.fullmatch(value):
        return
    if FULL_DATE_RE.fullmatch(value):
        try:
            date.fromisoformat(value)
        except ValueError:
            fail(f"schema: invalid publication date '{value}' in {where}")
        return
    fail(f"schema: invalid publication date '{value}' in {where} (want YYYY or YYYY-MM-DD)")


def check_registry(root):
    registry = root.find("operator-registry")
    if registry is None:
        fail("schema: missing operator-registry element")
    declared = {}
    for op in registry.findall("operator"):
        name = op.get("name")
        arity_text = op.get("arity")
        if name not in GLOBAL_OPERATORS:
            fail(f"unsupported operator '{name}' in operator-registry (not in the global registry)")
        if name in declared:
            fail(f"schema: duplicate operator-registry entry for '{name}'")
        if arity_text is None or not arity_text.isdigit():
            fail(f"schema: operator-registry entry '{name}' has no valid arity")
        if int(arity_text) != GLOBAL_OPERATORS[name]:
            fail(
                f"schema: operator '{name}' registered with arity {arity_text}, "
                f"global registry arity is {GLOBAL_OPERATORS[name]}"
            )
        declared[name] = int(arity_text)
    if not declared:
        fail("schema: operator-registry declares no operators")
    return declared


def check_sources(root):
    sources = root.findall("source")
    if not sources:
        fail("schema: document declares no source elements")
    ids = []
    for source in sources:
        sid = source.get("id")
        if not sid:
            fail("schema: source element without an id attribute")
        ids.append(sid)
        if not source.get("path"):
            fail(f"schema: source '{sid}' has no path attribute")
        if not is_sha256(source.get("sha256")):
            fail(f"schema: source '{sid}' sha256 attribute is not a 64-hex sha256")
        tags = [child.tag for child in source]
        for required in SOURCE_CHILDREN:
            if required not in tags:
                fail(f"schema: source '{sid}' is missing required element '{required}'")
        for tag in tags:
            if tag not in SOURCE_CHILDREN:
                fail(f"schema: source '{sid}' contains unexpected element '{tag}'")
        require_text(source.find("title"), f"source '{sid}' title")
        authors = source.findall("author")
        if not authors:
            fail(f"schema: source '{sid}' declares no author")
        for author in authors:
            require_text(author, f"source '{sid}' author")
        check_date(require_text(source.find("publication-date"), f"source '{sid}' publication-date"),
                   f"source '{sid}'")
        require_text(source.find("provenance"), f"source '{sid}' provenance")
    if len(ids) != len(set(ids)):
        fail("schema: duplicate source identifiers")
    return set(ids)


def declared_symbols(claim, cid):
    scopes = claim.find("variable-scopes")
    symbols = {}
    if scopes is None:
        return symbols
    for var in scopes.findall("variable"):
        name = var.get("name")
        if not name:
            fail(f"schema: claim '{cid}' has a variable entry without a name")
        if var.get("kind") not in VARIABLE_KINDS:
            fail(f"schema: claim '{cid}' variable '{name}' has invalid kind '{var.get('kind')}'")
        if var.get("binding") not in BINDINGS:
            fail(f"schema: claim '{cid}' variable '{name}' has invalid binding '{var.get('binding')}'")
        if not var.get("scope"):
            fail(f"schema: claim '{cid}' variable '{name}' has no scope")
        if name in symbols:
            fail(f"schema: claim '{cid}' declares variable '{name}' twice")
        symbols[name] = var.get("kind")
    return symbols


def declared_signatures(claim, cid):
    signatures = {}
    container = claim.find("operator-signatures")
    if container is None:
        return signatures
    for sig in container.findall("signature"):
        name = sig.get("operator")
        arity_text = sig.get("arity")
        if name not in GLOBAL_OPERATORS:
            fail(f"unsupported operator '{name}' in operator signatures of claim '{cid}'")
        if arity_text is None or not arity_text.isdigit() or int(arity_text) != GLOBAL_OPERATORS[name]:
            fail(
                f"schema: signature for operator '{name}' in claim '{cid}' has arity "
                f"'{arity_text}', global registry arity is {GLOBAL_OPERATORS[name]}"
            )
        if name in signatures:
            fail(f"schema: claim '{cid}' declares operator '{name}' in its signatures twice")
        signatures[name] = int(arity_text)
    return signatures


def node_children(element):
    return [child for child in element if child.tag in NODE_TAGS]


def walk_node(node, cid, registry, signatures, symbols, bound):
    tag = node.tag
    if tag == "number":
        value = node.get("value")
        if value is None or NUMERIC_RE.fullmatch(value) is None:
            fail(f"schema: claim '{cid}' has a number node with invalid value '{value}'")
        return
    if tag == "symbol":
        name = node.get("name")
        if not name:
            fail(f"schema: claim '{cid}' has a symbol node without a name")
        if name not in symbols and name not in bound:
            fail(
                f"schema: claim '{cid}' uses symbol '{name}' that is not declared "
                f"in its variable scopes and is not bound by an enclosing binder"
            )
        return
    if tag == "apply":
        operator = node.get("operator")
        if operator not in GLOBAL_OPERATORS:
            fail(f"unsupported operator '{operator}' in claim '{cid}' (not in the global operator registry)")
        if operator not in registry:
            fail(f"unsupported operator '{operator}' in claim '{cid}' (absent from the document operator-registry)")
        children = node_children(node)
        if len(children) != GLOBAL_OPERATORS[operator]:
            fail(
                f"operator arity mismatch in claim '{cid}': operator '{operator}' takes "
                f"{GLOBAL_OPERATORS[operator]} arguments, node has {len(children)}"
            )
        if operator not in signatures:
            fail(
                f"unsupported operator '{operator}' in claim '{cid}' "
                f"(not declared in the claim's operator signatures)"
            )
        for child in children:
            walk_node(child, cid, registry, signatures, symbols, bound)
        return
    if tag == "call":
        function = node.get("function")
        if not function:
            fail(f"schema: claim '{cid}' has a call node without a function name")
        if symbols.get(function) != "function" and function not in bound:
            fail(
                f"schema: claim '{cid}' calls function '{function}' that is not declared "
                f"as a function in its variable scopes"
            )
        for child in node_children(node):
            walk_node(child, cid, registry, signatures, symbols, bound)
        return
    if tag == "binder":
        kind = node.get("kind")
        variable = node.get("variable")
        if kind not in BINDER_KINDS:
            fail(f"schema: claim '{cid}' has a binder with invalid kind '{kind}'")
        if not variable:
            fail(f"schema: claim '{cid}' has a binder without a variable")
        body = node.find("body")
        if body is None:
            fail(f"schema: claim '{cid}' has a binder without a body")
        inner_bound = set(bound)
        inner_bound.add(variable)
        for wrapper_name in ("lower", "upper"):
            wrapper = node.find(wrapper_name)
            if wrapper is not None:
                for child in node_children(wrapper):
                    walk_node(child, cid, registry, signatures, symbols, bound)
        for child in node_children(body):
            walk_node(child, cid, registry, signatures, symbols, inner_bound)
        return
    fail(f"schema: claim '{cid}' contains unknown expression node '{tag}'")


def check_evidence(claim, cid):
    has_proof = False
    for evidence in claim.findall("evidence"):
        tool = evidence.get("tool")
        status = evidence.get("status")
        kind = evidence.get("kind")
        if not tool:
            fail(f"schema: claim '{cid}' has an evidence entry without a tool")
        if status not in EVIDENCE_STATUSES:
            fail(f"schema: claim '{cid}' has evidence with invalid status '{status}'")
        if kind is not None and kind not in EVIDENCE_KINDS:
            fail(f"schema: claim '{cid}' has evidence with invalid kind '{kind}'")
        if not is_sha256(evidence.get("artifact_sha256")):
            fail(f"schema: claim '{cid}' has evidence whose artifact_sha256 is not a 64-hex sha256")
        require_text(evidence.find("details"), f"claim '{cid}' evidence details")
        if tool in PROOF_TOOLS and status == "verified" and kind in (None, "formal-proof"):
            has_proof = True
    references = claim.find("formal-proof-references")
    if references is not None:
        for ref in references.findall("proof-reference"):
            if ref.get("tool") not in PROOF_TOOLS:
                fail(f"schema: claim '{cid}' has a proof reference with invalid tool '{ref.get('tool')}'")
            if ref.get("status") not in CLAIM_STATUSES:
                fail(f"schema: claim '{cid}' has a proof reference with invalid status '{ref.get('status')}'")
            if not ref.get("theorem"):
                fail(f"schema: claim '{cid}' has a proof reference without a theorem name")
            if not is_sha256(ref.get("artifact_sha256")):
                fail(f"schema: claim '{cid}' has a proof reference whose artifact_sha256 is not a 64-hex sha256")
            if ref.get("status") == "verified":
                has_proof = True
    return has_proof


def check_claim_extras(claim, cid):
    invariants = claim.find("candidate-invariants")
    if invariants is not None:
        for invariant in invariants.findall("invariant"):
            if invariant.get("status") not in CLAIM_STATUSES:
                fail(f"schema: claim '{cid}' has an invariant with invalid status '{invariant.get('status')}'")
            require_text(invariant, f"claim '{cid}' invariant")
    counterexamples = claim.find("counterexample-evidence")
    if counterexamples is not None:
        for counter in counterexamples.findall("counterexample"):
            if counter.get("report-status") not in REPORT_STATUSES:
                fail(
                    f"schema: claim '{cid}' has a counterexample with invalid "
                    f"report-status '{counter.get('report-status')}'"
                )
            artifact = counter.get("artifact_sha256")
            if artifact is not None and not is_sha256(artifact):
                fail(f"schema: claim '{cid}' has a counterexample whose artifact_sha256 is not a 64-hex sha256")
            require_text(counter.find("description"), f"claim '{cid}' counterexample description")
    residuals = claim.find("numerical-residuals")
    if residuals is not None:
        for residual in residuals.findall("residual"):
            if not residual.get("metric"):
                fail(f"schema: claim '{cid}' has a residual without a metric")
            for attr in ("value", "tolerance"):
                raw = residual.get(attr)
                if raw is None or NUMERIC_RE.fullmatch(raw) is None:
                    fail(f"schema: claim '{cid}' residual '{residual.get('metric')}' has invalid {attr} '{raw}'")
            if float(residual.get("tolerance")) < 0:
                fail(f"schema: claim '{cid}' residual '{residual.get('metric')}' has a negative tolerance")
    toolchains = claim.find("toolchain-versions")
    if toolchains is not None:
        for entry in toolchains.findall("toolchain"):
            if not entry.get("name") or not entry.get("version"):
                fail(f"schema: claim '{cid}' has a toolchain entry without a name or version")
    hashes = claim.find("source-hashes")
    if hashes is not None:
        for entry in hashes.findall("hash"):
            if entry.get("algorithm") != "sha256":
                fail(f"schema: claim '{cid}' has a hash entry with algorithm '{entry.get('algorithm')}'")
            if entry.get("role") not in HASH_ROLES:
                fail(f"schema: claim '{cid}' has a hash entry with invalid role '{entry.get('role')}'")
            if not is_sha256(entry.get("digest")):
                fail(f"schema: claim '{cid}' has a hash entry whose digest is not a 64-hex sha256")
    report = claim.find("verification-report")
    if report is not None and report.get("status") not in REPORT_STATUSES:
        fail(f"schema: claim '{cid}' has a verification report with invalid status '{report.get('status')}'")


def check_claims(root, source_ids, registry):
    claims = root.findall("claim")
    ids = []
    for claim in claims:
        cid = claim.get("id")
        if not cid:
            fail("schema: claim element without an id attribute")
        ids.append(cid)
    if len(ids) != len(set(ids)):
        fail("duplicate or missing claim identifiers")
    id_set = set(ids)
    graph = {}
    for claim in claims:
        cid = claim.get("id")
        if claim.get("source") not in source_ids:
            fail(f"unknown source: claim '{cid}' references source '{claim.get('source')}'")
        if claim.get("status") not in CLAIM_STATUSES:
            fail(f"invalid status: claim '{cid}' has status '{claim.get('status')}'")
        if claim.get("domain") not in DOMAINS:
            fail(f"schema: claim '{cid}' has invalid domain '{claim.get('domain')}'")
        line = claim.get("line")
        if line is not None and (not line.isdigit() or int(line) < 1):
            fail(f"schema: claim '{cid}' has invalid line attribute '{line}'")
        tags = [child.tag for child in claim]
        for tag in tags:
            if tag not in CLAIM_CHILDREN:
                fail(f"schema: claim '{cid}' contains unexpected element '{tag}'")
        positions = [CLAIM_CHILDREN.index(tag) for tag in tags]
        if positions != sorted(positions):
            fail(f"schema: claim '{cid}' has child elements out of the schema order")
        for required in REQUIRED_CLAIM_CHILDREN:
            if required not in tags:
                fail(f"schema: claim '{cid}' is missing required element '{required}'")
        require_text(claim.find("original-expression"), f"claim '{cid}' original-expression")
        assumptions = claim.find("assumptions")
        assumption_items = assumptions.findall("assumption")
        if not assumption_items:
            fail(f"schema: claim '{cid}' declares no assumption entries")
        for item in assumption_items:
            require_text(item, f"claim '{cid}' assumption")
        normalized = claim.find("normalized-expression")
        nodes = node_children(normalized)
        if len(nodes) != 1:
            fail(f"schema: claim '{cid}' normalized-expression must contain exactly one AST root node")
        symbols = declared_symbols(claim, cid)
        signatures = declared_signatures(claim, cid)
        walk_node(nodes[0], cid, registry, signatures, symbols, set())
        deps = []
        dependencies = claim.find("dependencies")
        if dependencies is not None:
            for dep in dependencies.findall("dependency"):
                ref = dep.get("ref")
                if dep.get("relation") not in DEPENDENCY_RELATIONS:
                    fail(f"schema: claim '{cid}' has a dependency with invalid relation '{dep.get('relation')}'")
                if ref not in id_set:
                    fail(f"unresolved dependency: claim '{cid}' depends on unknown claim '{ref}'")
                deps.append(ref)
        graph[cid] = deps
        has_proof = check_evidence(claim, cid)
        check_claim_extras(claim, cid)
        if claim.get("status") == "verified" and not has_proof:
            fail(
                f"unsubstantiated verified status: claim '{cid}' is marked verified but has no "
                f"formal-proof evidence (tool in lean/coq/agda/isabelle, status verified, "
                f"64-hex artifact hash)"
            )
    check_acyclic(graph)
    return claims


def check_acyclic(graph):
    state = {}
    stack = []

    def visit(node):
        state[node] = "open"
        stack.append(node)
        for nxt in graph.get(node, []):
            if state.get(nxt) == "open":
                start = stack.index(nxt)
                cycle = stack[start:] + [nxt]
                fail("dependency cycle detected: " + " -> ".join(cycle))
            if state.get(nxt) is None:
                visit(nxt)
        stack.pop()
        state[node] = "closed"

    for node in graph:
        if state.get(node) is None:
            visit(node)


def validate(path):
    try:
        tree = ET.parse(path)
    except ET.ParseError as exc:
        fail(f"malformed XML: {exc}")
    except OSError as exc:
        fail(f"unreadable file: {exc}")
    root = tree.getroot()
    if root.tag != "research":
        fail(f"schema: root element is '{root.tag}', expected 'research'")
    if root.get("version") != "2":
        fail(f"schema: root version is '{root.get('version')}', expected '2'")
    tags = [child.tag for child in root]
    for tag in tags:
        if tag not in ROOT_CHILDREN:
            fail(f"schema: root contains unexpected element '{tag}'")
    positions = [ROOT_CHILDREN.index(tag) for tag in tags]
    if positions != sorted(positions):
        fail("schema: root child elements are out of the schema order (operator-registry, source, claim)")
    registry = check_registry(root)
    source_ids = check_sources(root)
    claims = check_claims(root, source_ids, registry)
    return len(source_ids), len(claims)


def main(argv):
    if len(argv) != 2:
        print("usage: validate_v2.py DOCUMENT.xml", file=sys.stderr)
        return 1
    try:
        sources, claims = validate(argv[1])
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"VALID: {argv[1]} ({sources} sources, {claims} claims)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
