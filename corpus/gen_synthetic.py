#!/usr/bin/env python3
"""Deterministic generator for the synthetic corpus benchmark.

SYNTHETIC TEST DATA: every file this generator writes is synthetic test
data, generated for extractor benchmarking only.  No line is copied from
any historical or published document, and benchmark results over this
corpus say nothing about historical documents.

Determinism: the pseudo-random choices are driven by
``random.Random(SEED)`` with the fixed seed recorded below, files are
written in a fixed order, and every line is derived from the seed, the
file index, and the line number.  Re-running the generator with the same
Python ``random`` implementation reproduces the corpus byte for byte.

Layout: ``LINES_PER_FILE`` lines in each of ``len(FILES)`` files, one
file per supported extension, for a total of
``LINES_PER_FILE * len(FILES)`` lines.  Line 1 of every file is the
synthetic-data header.  Controlled hit density: exactly one planted hit
line every ``HIT_EVERY`` lines (line numbers divisible by
``HIT_EVERY``), i.e. a hit-line density of ``1 / HIT_EVERY``.  All other
lines are neutral filler whose wording avoids every extractor pattern.

Expected counts: each hit template below is annotated with the exact set
of extractor families it matches, worked out from the pattern lists in
``corpus/extract.py`` (note the overlaps: a "modular form" line also
matches moonshine via its ``modular`` branch, and a "hauptmodul" line
matches both moonshine and modular).  The generator counts expected
records per family purely from what it plants -- one expected record per
(line, family) pair in the annotation of each planted template -- and
prints those counts, plus writes them to ``expected-hits.json`` next to
the generated files, so the benchmark can check extractor recall
exactly.  The generator never runs the extractor.
"""
import json
import random
import sys
from pathlib import Path

SEED = 20261031
HIT_EVERY = 50
LINES_PER_FILE = 150000
FILES = [
    "synthetic-01.txt",
    "synthetic-02.tex",
    "synthetic-03.wl",
    "synthetic-04.m",
    "synthetic-05.lean",
    "synthetic-06.als",
    "synthetic-07.curry",
]

HEADER = ("SYNTHETIC TEST DATA -- generated synthetic corpus file for "
          "extractor benchmarking only; not a historical document.")

# Neutral filler templates: plain wording that matches no extractor
# pattern in any family.  "{n}" is a per-line counter value.
FILLER_TEMPLATES = [
    "Synthetic filler line {n} records plain counting steps in order.",
    "Synthetic entry {n} lists small whole numbers and simple sums.",
    "Synthetic note {n} describes sorting a short list of labels.",
    "Synthetic filler entry {n} walks through a basic addition drill.",
    "Synthetic line {n} keeps a running tally of evenly spaced marks.",
    "Synthetic entry {n} compares two short columns of plain figures.",
    "Synthetic note {n} rehearses a simple weekly schedule of tasks.",
    "Synthetic filler note {n} counts pebbles arranged in neat rows.",
]

# Planted hit templates: (text, families matched).  The family sets are
# derived by hand from the extractor pattern lists; the benchmark's exact
# recall check fails loudly if this annotation and the extractor ever
# disagree.  "{n}" is a per-line counter value.
HIT_TEMPLATES = [
    ("Synthetic planted line {n}: the moonshine correspondence is noted here.",
     ("moonshine",)),
    ("Synthetic planted line {n}: a vertex operator construction is noted here.",
     ("moonshine",)),
    ("Synthetic planted line {n}: the j-invariant value is noted here.",
     ("moonshine",)),
    ("Synthetic planted line {n}: the monster group is referenced here.",
     ("monster",)),
    ("Synthetic planted line {n}: a sporadic example is listed here.",
     ("monster",)),
    ("Synthetic planted line {n}: the character table entry is listed here.",
     ("monster",)),
    ("Synthetic planted line {n}: a representation entry is listed here.",
     ("monster",)),
    ("Synthetic planted line {n}: a lie algebra example is given here.",
     ("lie",)),
    ("Synthetic planted line {n}: the jacobi identity is stated here.",
     ("lie",)),
    ("Synthetic planted line {n}: a tangent space example is given here.",
     ("lie",)),
    ("Synthetic planted line {n}: a manifold example is given here.",
     ("lie",)),
    ("Synthetic planted line {n}: recursive subdivision is applied here.",
     ("geometry",)),
    ("Synthetic planted line {n}: a tensor entry is recorded here.",
     ("geometry",)),
    ("Synthetic planted line {n}: equivariance is checked here.",
     ("geometry",)),
    ("Synthetic planted line {n}: a coordinate transformation is recorded here.",
     ("geometry",)),
    ("Synthetic planted line {n}: an equivariant map is recorded here.",
     ("geometry",)),
    ("Synthetic planted line {n}: a modular form is recorded here.",
     ("moonshine", "modular")),
    ("Synthetic planted line {n}: the q-expansion is recorded here.",
     ("modular",)),
    ("Synthetic planted line {n}: a McKay-Thompson series is recorded here.",
     ("modular",)),
    ("Synthetic planted line {n}: the hauptmodul is recorded here.",
     ("moonshine", "modular")),
    ("Synthetic planted line {n}: moonshine and the monster group appear together here.",
     ("moonshine", "monster")),
]

FAMILIES = ["moonshine", "monster", "lie", "geometry", "modular"]


def generate(outdir):
    """Write the synthetic corpus under outdir; return expected counts."""
    outdir.mkdir(parents=True, exist_ok=True)
    rng = random.Random(SEED)
    expected = {family: 0 for family in FAMILIES}
    total_lines = 0
    total_hit_lines = 0
    for name in FILES:
        path = outdir / name
        with path.open("w", encoding="utf-8", newline="\n") as f:
            f.write(HEADER + "\n")
            total_lines += 1
            for lineno in range(2, LINES_PER_FILE + 1):
                total_lines += 1
                if lineno % HIT_EVERY == 0:
                    text, families = HIT_TEMPLATES[rng.randrange(len(HIT_TEMPLATES))]
                    f.write(text.format(n=lineno) + "\n")
                    total_hit_lines += 1
                    for family in families:
                        expected[family] += 1
                else:
                    text = FILLER_TEMPLATES[rng.randrange(len(FILLER_TEMPLATES))]
                    f.write(text.format(n=lineno) + "\n")
    expected_path = outdir / "expected-hits.json"
    with expected_path.open("w", encoding="utf-8") as f:
        json.dump({
            "synthetic": True,
            "seed": SEED,
            "hit_every": HIT_EVERY,
            "lines_per_file": LINES_PER_FILE,
            "files": FILES,
            "total_lines": total_lines,
            "planted_hit_lines": total_hit_lines,
            "expected_records_per_family": expected,
            "expected_records_total": sum(expected.values()),
        }, f, indent=2, sort_keys=True)
        f.write("\n")
    return expected, total_lines, total_hit_lines


def main():
    outdir = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / "synthetic"
    expected, total_lines, total_hit_lines = generate(outdir)
    print("SYNTHETIC TEST DATA -- generated corpus, not historical documents")
    print(f"seed: {SEED}")
    print(f"files: {len(FILES)}")
    print(f"total lines: {total_lines}")
    print(f"planted hit lines: {total_hit_lines} (1 every {HIT_EVERY} lines)")
    print("expected records per family:")
    for family in FAMILIES:
        print(f"  {family}: {expected[family]}")
    print(f"expected records total: {sum(expected.values())}")


if __name__ == "__main__":
    main()
