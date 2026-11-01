# Verification-workload allocation model

A small verification-workload allocation problem: choose a subset of
4 candidate verification tasks to maximise total coverage subject to
a total-hours budget and one linking constraint.

## Instance

| Task | Hour cost | Coverage value |
|------|-----------|----------------|
| t1   | 3         | 10             |
| t2   | 2         | 9              |
| t3   | 4         | 13             |
| t4   | 3         | 8              |

- Budget B = 8 hours: `3 t1 + 2 t2 + 4 t3 + 3 t4 <= 8`
- Linking constraint: t2 requires t1: `t2 <= t1`, i.e. `t2 - t1 <= 0`
- Variables: `t1, t2, t3, t4` are binary (1 = task selected).
- Objective: maximise `10 t1 + 9 t2 + 13 t3 + 8 t4`.

## Hand computation (explicit enumeration)

All subsets satisfying `t2 <= t1` and total cost `<= 8`:

| Subset       | Cost        | Coverage     | Feasible |
|--------------|-------------|--------------|----------|
| (none)       | 0           | 0            | yes      |
| t1           | 3           | 10           | yes      |
| t3           | 4           | 13           | yes      |
| t4           | 3           | 8            | yes      |
| t2 alone     | 2           | 9            | no — violates `t2 <= t1` |
| t1, t2       | 3+2 = 5     | 10+9 = 19    | yes      |
| t1, t3       | 3+4 = 7     | 10+13 = 23   | yes      |
| t1, t4       | 3+3 = 6     | 10+8 = 18    | yes      |
| t3, t4       | 4+3 = 7     | 13+8 = 21    | yes      |
| t2, t3       | —           | —            | no — violates `t2 <= t1` |
| t2, t4       | —           | —            | no — violates `t2 <= t1` |
| t1, t2, t3   | 3+2+4 = 9   | 28           | no — cost 9 > 8 |
| t1, t2, t4   | 3+2+3 = 8   | 10+9+8 = 27  | yes      |
| t1, t3, t4   | 3+4+3 = 10  | 31           | no — cost 10 > 8 |
| t2, t3, t4   | —           | —            | no — violates `t2 <= t1` |
| t1, t2, t3, t4 | 3+2+4+3 = 12 | 40        | no — cost 12 > 8 |

The best feasible coverage in the table is 27, attained only by
{t1, t2, t4}. The next-best feasible value is 23 ({t1, t3}), so the
optimum is unique.

**Hand-computed optimum: objective 27, at t1 = 1, t2 = 1, t3 = 0, t4 = 1,
total cost 8.**

## Files

- `workload.lp` — the same model in LP format; this is the file executed
  by HiGHS.
- `workload.mps` — the same model in MPS format.
- `highs-run.txt` — full HiGHS solver output for `workload.lp`.
- `../../workload.mod` — the same model written in AMPL syntax, as a
  separate artifact. AMPL is not installed and that file has not been
  executed by an AMPL runtime.
