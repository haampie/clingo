# Optimizing Clingo for Spack's Dependency Resolver

## Goal

Make clingo faster when solving Spack's dependency resolution problem. The benchmark runs
clingo directly on a pre-generated `problem.lp` file (exported from Spack's `cmake` solve).
Clingo reports `Total` and `Solving` times via `--stats=2`; grounding time is derived as
Total - Solving. The grounding and solving phases are where your optimizations matter.

## Architecture

Spack encodes package dependency constraints as an Answer Set Program (logic program).
Clingo processes it in two phases:

1. **Grounding** (libgringo): parses the logic program and instantiates all rules with
   concrete atoms → produces a propositional program.
2. **Solving** (clasp): runs CDNL (Conflict-Driven Nogood Learning) search over the
   propositional program to find answer sets.

Data flow: logic program text → libgringo (parse + ground) → clasp (solve) → answer sets.

## Source code scope

All C++ source is fair game:

- **`clasp/src/`** — the solver (propagation, conflict analysis, clause learning)
- **`libgringo/src/`** — the grounder (parsing, rule instantiation, term evaluation)
- **`libclingo/src/`** — API and control layer connecting grounding and solving

### Key hot-path files

- `clasp/src/solver.cpp` — propagation loop, conflict analysis
- `clasp/src/clause.cpp` — clause storage, watched literal management
- `clasp/src/logic_program.cpp` — ASP-to-SAT translation
- `libgringo/src/ground/statements.cc` — rule instantiation during grounding

## Workflow

Repeat this loop:

1. Make **ONE** change to the clingo source code
2. Build: `experiment/build.sh`
3. Benchmark: `experiment/bench.sh`
4. **ALWAYS** append the change description and benchmark result to `experiment/log.md`,
   even if performance got worse — we must track what was tried
5. If performance improved → commit the change
6. If performance regressed → reset the change (`git checkout -- .`)
7. Go to step 1

## How to profile

Run `experiment/profile.sh` to capture stack samples for 10 seconds using macOS `sample`.
Output goes to `profile_output.txt`. Look for hot functions and deep call stacks to find
optimization targets.

## Build details

`experiment/build.sh` uses Spack to build clingo with:
- Build type: RelWithDebInfo (optimized + debug symbols)
- PGO (Profile-Guided Optimization) + LTO (Link-Time Optimization)
- Install prefix: `/tmp/x`

The build wipes `build-darwin-*` and `reports/` directories, then rebuilds from scratch.

## What counts as meaningful

The benchmark has roughly **±0.5s variance** between runs. An improvement must show
**>0.2s improvement on median** to be considered signal rather than noise. The benchmark
script runs 3 iterations and reports the median to reduce noise.
