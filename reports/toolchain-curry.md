# Toolchain manifest — Curry / PAKCS + SWI-Prolog (Directive §3)

Section owner: Phase 1a recovery run, 2026-10-31.
All results below were produced by executing the named commands on this
VM in this run. Raw outputs are saved under `curry/battery/outputs/`.

## Versions (as reported by the tools themselves)

- SWI-Prolog: `SWI-Prolog version 9.0.4 for x86_64-linux`
  (Debian/Ubuntu packages `swi-prolog-core`, `swi-prolog-core-packages`,
  `swi-prolog-nox`, all `9.0.4+dfsg-3.1ubuntu4`, plus dependency
  `libossp-uuid16 1.6.2-1.3ubuntu1`).
- PAKCS: banner `PAKCS - the Portland Aachen Kiel Curry System`,
  `Version 3.9.0 of 2025-10-29 (swi 9.0)` — the `(swi 9.0)` suffix is
  PAKCS's own report that it runs on the SWI-Prolog backend.
- Build dependency added: `envsubst (GNU gettext-runtime) 0.21`
  (package `gettext-base 0.21-14ubuntu2`).

## Install sources

### SWI-Prolog

The four `.deb` files were already present on this VM under
`~/workspace/.tools/swi-prolog/` (downloaded 2026-10-28) and are Ubuntu
24.04 (noble) packaging of SWI-Prolog 9.0.4. They were used because this
VM is Ubuntu 24.04 and their dependencies (`libssl3t64`, `libedit2`,
`libgmp10`, `libarchive13t64`, `libyaml-0-2`, `libpcre2-8-0`,
`libreadline8t64`, `libtinfo6`, `zlib1g`, `libcrypt1`) are all present
in the noble system; the Debian bookworm pool
(`http://ftp.debian.org/debian/pool/main/s/swi-prolog/`, checked live
this run, HTTP 200, lists the bookworm build `9.0.4+dfsg-2`) targets
bookworm library sonames and was not used. No `apt` was used.

Install command (run as root):

```
dpkg -i libossp-uuid16_1.6.2-1.3ubuntu1_amd64.deb \
        swi-prolog-core_9.0.4+dfsg-3.1ubuntu4_amd64.deb \
        swi-prolog-core-packages_9.0.4+dfsg-3.1ubuntu4_amd64.deb \
        swi-prolog-nox_9.0.4+dfsg-3.1ubuntu4_amd64.deb
```

The metapackage `swi-prolog_9.0.4+dfsg-3.1ubuntu4_amd64.deb` was saved
but not installed (it additionally requires the doc and X packages,
which the SWI backend of PAKCS does not need).

Durability: the `.deb` set is saved under `~/workspace/.tools/debs/swi/`
(SHA-256: core `c009da7275e82e72a6ab81c86e8250953ce856afc8585cfe23b5654499df1ff8`,
core-packages `59e9fc6e3dff8d2c4416674673175f968211af2a86fe0fe9cc136c2eb9690c20`,
nox `99c7548f165fbeaa6ee283f8e329144c2e440f0644a4d526a34201c313effedc`,
libossp-uuid16 `d407dea00a93151272ad3f716f1fc2885a907dd8ad0230091093cacf4766a9dc`)
and the gettext-base `.deb` under `~/workspace/.tools/debs/gettext/`
(SHA-256 `3e2806e94aba780cac11961ede06bffd14d4b840c4085be33d597ec93773fba5`).
`scripts/reinstall-swi.sh` in this repository reinstalls both sets with
`dpkg -i` after a VM replacement and prints the restored version.

### gettext-base (for `envsubst`)

Downloaded this run from the Ubuntu pool:
`http://archive.ubuntu.com/ubuntu/pool/main/g/gettext/gettext-base_0.21-14ubuntu2_amd64.deb`,
installed with `dpkg -i`. Needed only because the PAKCS build generates
`src/pakcsversion.pl` by running `envsubst` over a template.

### PAKCS

Download page: `https://www.curry-lang.org/pakcs/download.html`
(the current PAKCS site operated by the Kiel Curry group; the legacy
`https://www.informatik.uni-kiel.de/~pakcs/download.html` answered
curl with an empty body in this run, and the same release files are
served from curry-lang.org). The page lists PAKCS 3.9.0 (29/10/25) as
the "Current release", built on Ubuntu 24.04; a 3.10.0 dated 08/10/26
is listed as the development release and was not used. The GitHub
mirror route was not needed.

Tarball used:
`https://www.curry-lang.org/pakcs/download/pakcs-3.9.0-amd64-Linux.tar.gz`
(6,578,555 bytes, SHA-256
`6d0eb1e2f20bfd7514373d3c83305fdccb33cae8806251cb53d88a75df7389fe`),
saved at `~/workspace/.tools/downloads/pakcs-3.9.0-amd64-Linux.tar.gz`
and unpacked in place to `~/workspace/.tools/pakcs-3.9.0`
(the distribution's build hardcodes its own directory, so it was
unpacked directly at its final location).

Build command (SWI-Prolog on PATH at `/usr/bin/swipl`):

```
cd ~/workspace/.tools/pakcs-3.9.0
LC_ALL=C.UTF-8 make SWIPROLOG=/usr/bin/swipl
```

Build history, recorded because the first two attempts failed:

1. First `make` failed at the `pakcsversion.pl` target:
   `/bin/sh: 1: envsubst: not found`, `make[3]: *** [Makefile:282:
   .../src/pakcsversion.pl] Error 127`. Fixed by installing
   gettext-base (above).
2. Second `make` failed while building the saved Prolog state with
   `ERROR: Unknown procedure: basics:compilerMajorVersion/1`. Cause:
   the failed first attempt had already created `src/pakcsversion.pl`
   as a 0-byte file (shell redirection before `envsubst` ran), and
   make then treated it as up to date. Fixed by deleting the empty
   file and rebuilding; the generated file then contained
   `compilerMajorVersion(3).` etc. as expected.
3. Third `make` completed with exit code 0 (`Make finished` in the
   build log). The bulk of the elapsed time was compiling the CPM
   tool (`Compiling Curry program "CPM.Main"...`) under the SWI
   backend. The resulting `bin/` contains `pakcs`, `curry -> pakcs`,
   `pakcs-frontend`, `cypm`, `pakcs-cypm`, `cleancurry`, `pakcs-fcypp`.

Runtime environment used for every verification below:

```
export PATH=$HOME/workspace/.tools/pakcs-3.9.0/bin:$PATH
export LC_ALL=C.UTF-8
```

## SWI-Prolog verification

Commands and raw output are in `curry/battery/outputs/0-swipl.txt`:

- `swipl --version` → `SWI-Prolog version 9.0.4 for x86_64-linux`
- `swipl -g "append([1,2],[3],X), write(X), nl, halt" -t halt` →
  `[1,2,3]`, exit 0.

Status: SWI-Prolog — VERIFIED.

## Curry verification battery (Directive §3)

Programs live in `curry/battery/`; each was executed by loading it
into the PAKCS REPL and evaluating `main`, with the raw session saved
in `curry/battery/outputs/`. One API fact about this PAKCS base
library version shaped the programs: `Control.Search.AllValues`
exports `getAllValues :: a -> IO [a]` (and `getOneValue`,
`getAllFailures`); the pure `allValues :: a -> [a]` is exported by
`Control.Search.Unsafe`. The battery uses `getAllValues` inside the
IO `main`, which is the mechanism this distribution documents for
encapsulating search in IO. A first run of the Split program with
`allValues` imported from `Control.Search.AllValues` failed with the
frontend error `Module Control.Search.AllValues does not export
allValues`; that failed session was overwritten by the corrected run
in `outputs/b-split.txt`, and the error text is recorded here.

### 1. Compiler/interpreter startup

Command: `printf "1+2\n:quit\n" | pakcs`
Output (`outputs/a-startup.txt`): the PAKCS banner with
`Version 3.9.0 of 2025-10-29 (swi 9.0)`, then the evaluated result
`3`, exit 0.

Status: VERIFIED.

### 2. Logic variables and unification

Program: `curry/battery/Split.curry`. The free variables `xs`, `ys`
are constrained by the equational constraint `xs ++ ys =:= [1, 2]`;
`getAllValues` enumerates every unifier.
Command: `printf ":load Split\nmain\n:quit\n" | pakcs`
Output (`outputs/b-split.txt`):
`[([],[1,2]),([1],[2]),([1,2],[])]`, exit 0 — all three splits.

Status: VERIFIED.

### 3. Recursive Horn-clause resolution

Program: `curry/battery/Family.curry`. Ground `parent` facts plus
`ancestor` with a base clause and a recursive clause
(`parent x y && ancestor y z`, intermediate `y` a free variable).
Command: `printf ":load Family\nmain\n:quit\n" | pakcs`
Output (`outputs/c-family.txt`):
`["bob","ada","cy","dee","eli"]`, exit 0 — the direct children
bob/ada plus cy, dee, eli reached only through recursion. The raw
output also contains two frontend warnings (non-exhaustive `parent`
patterns; `ancestor` potentially non-deterministic due to overlapping
rules), which are expected for this relational style.

Status: VERIFIED.

### 4. Nondeterministic alternatives

Program: `curry/battery/Coin.curry`. `coin` is defined by two
overlapping rules (`coin = Heads`, `coin = Tails`); values are
collected with `getAllValues` from `Control.Search.AllValues`.
Command: `printf ":load Coin\nmain\n:quit\n" | pakcs`
Output (`outputs/d-coin.txt`): `[Heads,Tails]` for one flip and
`[(Heads,Heads),(Heads,Tails),(Tails,Heads),(Tails,Tails)]` for two
independent flips, exit 0.

Status: VERIFIED.

### 5. Recursive backtracking

Program: `curry/battery/PermSort.curry`. `insert` nondeterministically
places an element at every list position, so `perm` enumerates all
permutations; `psort` adds the `isSorted` constraint, so unsorted
candidates must be abandoned by backtracking.
Command: `printf ":load PermSort\nmain\n:quit\n" | pakcs`
Output (`outputs/e-permsort.txt`): all 6 permutations of `[3,1,2]`
(`[[2,1,3],[2,3,1],[1,2,3],[1,3,2],[3,2,1],[3,1,2]]`), then
`psort [3,1,2]` yields exactly `[[1,2,3]]`, exit 0.

Status: VERIFIED.

### 6. Occurs-check behaviour

Program: `curry/battery/Occurs.curry` (plus the print driver
`OccursPrint.curry`). The constraint `x =:= N x (L 7)` unifies a
variable with a term containing itself (the `X = f(X)` case).
`probe` walks the left spine with a 5-step budget and returns 99 if
no leaf is reached, so a successfully built cyclic structure would
produce the value 99; the finite control term produces 7.
Three probes were executed:

- Encapsulated probe (`outputs/f-occurs.txt`): `main` prints the
  finite control `7`, then `getAllValues cycProbe` returns `[]`.
- Print-the-term probe (`outputs/f-occurs-print.txt`):
  `getAllValues cyc` (collecting the cyclic term itself) returns `[]`.
- Direct REPL evaluation (`outputs/f-occurs-direct.txt`): evaluating
  `cycProbe` at the REPL prints `*** No value found!`, exit 2.

Observed behaviour: in this PAKCS version the cyclic unification
produces no value at all — it neither builds an observable cyclic
(rational-tree) structure nor diverges; every probe fails finitely.
The battery does not distinguish whether this rejection happens in
the constraint solver itself or in the search encapsulation, and no
stronger claim is made.

Status: VERIFIED (behaviour recorded as observed).

### 7. Cyclic-goal handling and bounded search

Programs: `curry/battery/Cycle.curry` (bounded and naive closures)
and `curry/battery/CycleNaive.curry` (naive driver). The edge graph
contains the cycle a -> b -> a plus b -> c; the target `"zzz"` is
unreachable.

- Naive, unbounded: command
  `printf ":load CycleNaive\nmain\n:quit\n" | timeout 60 pakcs`
  produced no result and was killed by the timeout, exit 124
  (`outputs/g-cycle-naive-timeout.txt`) — the naive closure loops
  around the a-b cycle.
- Bounded: `reachN` is the same closure with an explicit fuel
  parameter (recursion depth bound). Command
  `printf ":load Cycle\nmain\n:quit\n" | pakcs`
  (`outputs/g-cycle-bounded.txt`) terminated with exit 0: the
  unreachable-target query returns `[]`, and the bounded reachability
  query from `"a"` with fuel 5 returns
  `["b","a","c","b","a","c","b","a","c"]` — each reachable node once
  per distinct derivation path within the bound.

Status: VERIFIED.

## Summary

- SWI-Prolog 9.0.4: VERIFIED (installed from saved noble `.deb` set,
  reinstall script at `scripts/reinstall-swi.sh`).
- PAKCS 3.9.0 (SWI backend): VERIFIED, installed at
  `~/workspace/.tools/pakcs-3.9.0`, `bin/pakcs` on PATH per the
  environment block above.
- Directive §3 items 1–7: all VERIFIED by execution, with the
  occurs-check item's status meaning the actual behaviour (finite
  failure, no value, no divergence) was observed and recorded.
