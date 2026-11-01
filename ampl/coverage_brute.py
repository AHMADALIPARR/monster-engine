#!/usr/bin/env python3
"""Brute-force optimum for the dependency-coverage optimisation.

The universe is the set of machine-checkable contract items, read
from contracts/families.json (every item whose kind is not
abstract-only). Each verification task below covers a named subset of
that universe at a stated cost. The problem: select a minimum-cost
set of tasks whose subsets cover every checkable item. Because every
checkable item has its own covering constraint, any feasible
selection automatically covers every depends_on target of every
covered item (all depends_on targets of checkable items are
themselves checkable -- this is asserted below).

This script also parses ampl/coverage.lp and asserts that the LP's
objective coefficients and covering constraints are exactly the task
table below, so the solver model and this enumeration cannot drift
apart silently.

Enumerates all 2^12 task subsets and prints the true optimum.
"""

import json
import re
from itertools import combinations
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
FAMILIES = json.loads((ROOT / "contracts" / "families.json").read_text(encoding="utf-8"))

ITEMS = [it for fam in FAMILIES["families"] for it in fam["items"]]
CHECKABLE = [it["id"] for it in ITEMS if it["kind"] != "abstract-only"]
CHECKABLE_SET = set(CHECKABLE)
BY_ID = {it["id"]: it for it in ITEMS}

# Task id -> (cost, covered contract ids). Mirrors ampl/coverage.lp
# and ampl/coverage.mod; the LP cross-check below enforces the mirror.
TASKS = {
    "mon_core": (4, ["MON-identity", "MON-closure", "MON-associativity",
                     "MON-inverses"]),
    "mon_repr": (4, ["MON-homomorphism", "MON-nonhomomorphism",
                     "MON-character-compat", "MON-conjugacy"]),
    "mon_full": (7, ["MON-identity", "MON-closure", "MON-associativity",
                     "MON-inverses", "MON-homomorphism", "MON-nonhomomorphism",
                     "MON-character-compat", "MON-conjugacy"]),
    "moon_data": (3, ["MOON-j-coeffs", "MOON-mckay-identity",
                      "MOON-character-decomposition"]),
    "moon_j": (2, ["MOON-j-coeffs", "MOON-mckay-identity"]),
    "lie_bracket": (3, ["LIE-structure-constants", "LIE-antisymmetry",
                        "LIE-jacobi"]),
    "lie_full": (5, ["LIE-structure-constants", "LIE-antisymmetry",
                     "LIE-jacobi", "LIE-action-composition"]),
    "lie_action": (2, ["LIE-action-composition", "GEO-tensor-shape"]),
    "geo_grid": (3, ["GEO-subdivision", "GEO-forward-inverse",
                     "GEO-tensor-shape"]),
    "geo_full": (5, ["GEO-subdivision", "GEO-forward-inverse",
                     "GEO-tensor-shape", "GEO-reconstruction",
                     "GEO-rank-preservation"]),
    "geo_measure": (3, ["GEO-subdivision", "GEO-reconstruction",
                        "GEO-rank-preservation"]),
    "cross_finite": (2, ["MON-closure", "LIE-jacobi", "GEO-subdivision"]),
}


def check_task_table():
    union = set()
    for task, (_cost, covers) in TASKS.items():
        extra = set(covers) - CHECKABLE_SET
        assert not extra, f"{task} covers non-checkable items {extra}"
        assert len(covers) == len(set(covers)), f"{task} lists an item twice"
        union |= set(covers)
    assert union == CHECKABLE_SET, f"tasks do not cover: {CHECKABLE_SET - union}"
    # Dependency targets of checkable items are checkable, so a
    # feasible cover of all checkable items is dependency-closed.
    edges = 0
    for item_id in CHECKABLE:
        for dep in BY_ID[item_id].get("depends_on", []):
            edges += 1
            assert dep in CHECKABLE_SET, (
                f"{item_id} depends on {dep}, which is not checkable"
            )
    return edges


def cross_check_lp():
    text = (HERE / "coverage.lp").read_text(encoding="utf-8")
    obj_match = re.search(r"^\s*obj:\s*(.+)$", text, re.MULTILINE)
    lp_costs = {
        var: int(coeff)
        for coeff, var in re.findall(r"(\d+)\s+([A-Za-z_][A-Za-z0-9_]*)",
                                     obj_match.group(1))
    }
    table_costs = {t: c for t, (c, _covers) in TASKS.items()}
    assert lp_costs == table_costs, (
        f"LP objective {lp_costs} != task table costs {table_costs}"
    )
    # Constraint names in coverage.lp are the item id lowercased with
    # '-' replaced by '_', prefixed cov_. Rebuild the cover relation.
    lp_cover_of_item = {}
    for line in text.splitlines():
        m = re.match(r"\s*cov_([a-z0-9_]+):\s*(.+?)\s*>=\s*1\s*$", line)
        if not m:
            continue
        slug, rhs = m.group(1), m.group(2)
        tasks = {t.strip() for t in rhs.split("+")}
        lp_cover_of_item[slug] = tasks
    assert len(lp_cover_of_item) == len(CHECKABLE), (
        f"LP has {len(lp_cover_of_item)} covering constraints, "
        f"expected {len(CHECKABLE)}"
    )
    for item in CHECKABLE:
        slug = item.lower().replace("-", "_")
        expected_tasks = {t for t, (_c, covers) in TASKS.items() if item in covers}
        assert lp_cover_of_item.get(slug) == expected_tasks, (
            f"LP constraint for {item}: {lp_cover_of_item.get(slug)} "
            f"!= task table {expected_tasks}"
        )


def brute_force():
    task_ids = sorted(TASKS)
    best_cost = None
    best_sets = []
    for r in range(len(task_ids) + 1):
        for combo in combinations(task_ids, r):
            covered = set()
            cost = 0
            for t in combo:
                c, covers = TASKS[t]
                cost += c
                covered |= set(covers)
            if covered == CHECKABLE_SET:
                if best_cost is None or cost < best_cost:
                    best_cost = cost
                    best_sets = [combo]
                elif cost == best_cost:
                    best_sets.append(combo)
    return best_cost, best_sets


def main():
    edges = check_task_table()
    cross_check_lp()
    best_cost, best_sets = brute_force()
    print(f"checkable contract items (universe size): {len(CHECKABLE)}")
    print(f"depends_on edges among checkable items: {edges} "
          f"(all targets checkable, so full coverage is dependency-closed)")
    print(f"verification tasks: {len(TASKS)}")
    print(f"covering constraints: {len(CHECKABLE)} (one per checkable item)")
    print("coverage.lp cross-check: objective costs and covering "
          "constraints match the task table above")
    print(f"subsets enumerated: {2 ** len(TASKS)}")
    print(f"brute-force optimum cost: {best_cost}")
    print(f"optimal solutions found: {len(best_sets)}")
    for s in best_sets:
        print(f"optimal set: {', '.join(s)} "
              f"(cost {sum(TASKS[t][0] for t in s)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
