#!/usr/bin/env python3
"""Independent checker for the Phase 4 Curry resolution program.

Recomputes, from contracts/families.json alone and with plain graph
algorithms (no Curry), the

  * blocked set    -- abstract-only items, plus every item that
                      transitively depends on a blocked item
                      (fixpoint over the reversed dependency graph);
  * resolvable set -- all items minus the blocked set;
  * transitive dependencies of MON-homomorphism and
    MON-character-compat (plain DFS closure);
  * derivation-tree node set for MON-character-compat -- the item
    itself plus everything it transitively depends on;

and compares each against the corresponding set printed by
Resolve.curry in its run output (default: outputs/resolve-output.txt,
or the file named on the command line).  The Curry program prints
sets as Curry lists of strings, e.g. BLOCKED: ["a","b"], which are
also valid Python literals, and prints derivation trees between
BEGIN-DERIVATION <id> / END-DERIVATION <id> markers with one
"NODE item=<id> clause=<name> ..." line per node.

Prints the comparison and exits nonzero on any mismatch.
"""

import ast
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FAMILIES = os.path.normpath(os.path.join(HERE, "..", "..", "contracts", "families.json"))
CHECK_ITEM = "MON-character-compat"
TRANS_ITEMS = ["MON-homomorphism", "MON-character-compat"]


def load_graph():
    with open(FAMILIES, encoding="utf-8") as fh:
        data = json.load(fh)
    items = {}
    deps = {}
    for fam in data["families"]:
        for it in fam["items"]:
            items[it["id"]] = it
            deps[it["id"]] = list(it["depends_on"])
    return items, deps


def transitive_deps(deps, start):
    seen = set()
    stack = list(deps[start])
    while stack:
        cur = stack.pop()
        if cur in seen:
            continue
        seen.add(cur)
        stack.extend(deps[cur])
    return seen


def compute_expected(items, deps):
    blocked = set(i for i, it in items.items() if it["kind"] == "abstract-only")
    # Fixpoint: an item becomes blocked when any of its direct
    # dependencies is blocked.
    changed = True
    while changed:
        changed = False
        for i, ds in deps.items():
            if i not in blocked and any(d in blocked for d in ds):
                blocked.add(i)
                changed = True
    resolvable = set(items) - blocked
    return blocked, resolvable


def parse_curry_list(text, label):
    m = re.search(r"^%s: (\[.*\])$" % re.escape(label), text, re.MULTILINE)
    if not m:
        raise SystemExit("check: label %r not found in Curry output" % label)
    return set(ast.literal_eval(m.group(1)))


def parse_trans(text, item):
    return parse_curry_list(text, "TRANS " + item)


def parse_derivation_nodes(text, item):
    m = re.search(
        r"^BEGIN-DERIVATION %s$(.*?)^END-DERIVATION %s$"
        % (re.escape(item), re.escape(item)),
        text,
        re.MULTILINE | re.DOTALL,
    )
    if not m:
        raise SystemExit("check: derivation block for %r not found" % item)
    nodes = re.findall(r"NODE item=(\S+) clause=(\S+)", m.group(1))
    return set(n for n, _ in nodes), set(c for _, c in nodes)


def compare(name, expected, actual):
    ok = expected == actual
    print("%s: expected %d, curry %d, %s"
          % (name, len(expected), len(actual), "AGREE" if ok else "MISMATCH"))
    if not ok:
        print("  expected-only: %s" % sorted(expected - actual))
        print("  curry-only:    %s" % sorted(actual - expected))
    return ok


def main():
    out_path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "outputs", "resolve-output.txt")
    with open(out_path, encoding="utf-8") as fh:
        text = fh.read()

    items, deps = load_graph()
    exp_blocked, exp_resolvable = compute_expected(items, deps)

    ok = True
    ok &= compare("ALL", set(items), parse_curry_list(text, "ALL"))
    ok &= compare("BLOCKED", exp_blocked, parse_curry_list(text, "BLOCKED"))
    ok &= compare("RESOLVABLE", exp_resolvable, parse_curry_list(text, "RESOLVABLE"))
    for item in TRANS_ITEMS:
        ok &= compare("TRANS " + item, transitive_deps(deps, item), parse_trans(text, item))

    exp_nodes = {CHECK_ITEM} | transitive_deps(deps, CHECK_ITEM)
    act_nodes, act_clauses = parse_derivation_nodes(text, CHECK_ITEM)
    ok &= compare("DERIVATION-NODES " + CHECK_ITEM, exp_nodes, act_nodes)
    bad_clauses = act_clauses - {"derivation-base", "derivation-step"}
    if bad_clauses:
        print("DERIVATION-CLAUSES %s: unexpected clause names %s" % (CHECK_ITEM, sorted(bad_clauses)))
        ok = False
    else:
        print("DERIVATION-CLAUSES %s: all nodes cite derivation-base/derivation-step, AGREE" % CHECK_ITEM)

    # Auxiliary moonshine chain (MoonshineChain.curry, mirroring the
    # DependencyChain fact of alloy/moonshine_dependencies.als):
    # GradedDim -> McKayDecomp -> JCoeff2 -> JCoeff1, so the
    # transitive dependencies of GradedDim are the other three nodes.
    exp_moon = {"JCoeff1", "JCoeff2", "McKayDecomp"}
    ok &= compare("MOONCHAIN TRANS GradedDim", exp_moon,
                  parse_curry_list(text, "MOONCHAIN TRANS GradedDim"))

    if "BOUNDED CYCLIC:" not in text:
        print("BOUNDED CYCLIC: line not found in Curry output, MISMATCH")
        ok = False
    else:
        print("BOUNDED CYCLIC: line present in Curry output, AGREE")

    print("check: %s" % ("ALL COMPARISONS AGREE" if ok else "MISMATCH FOUND"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
