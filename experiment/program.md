# Spack Autoresearch Program

## Context

Spack is a package manager that uses Clingo-based logic programming to resolve dependencies.

Your goal is to find optimal flags and heuristics to improve the solver's performance on a benchmark problem. The benchmark is solving `paraview.lp` (a real Spack concretization problem). The baseline runtime is ~19.7s.

## Files

**You may modify:**
- `experiment/run.sh` — clingo invocation with solver flags (configuration, opt-strategy, heuristic mode, etc.)
- `experiment/heuristic.lp` — `#heuristic` directives that guide the Domain heuristic

**Do not modify** (static benchmark input):
- `experiment/concretize.lp`
- `experiment/direct_dependency.lp`
- `experiment/libc_compatibility.lp`
- `experiment/paraview.lp`

**Scratchpad** (create if missing, always update):
- `experiment/scratchpad.md` — observations, hypotheses, and next plans

**Reference material** — read freely to understand solver options and heuristic semantics:
- Clingo/clasp CLI option definitions: `libclingo/src/clingo_app.cc`
- `#heuristic` directive semantics: `libpyclingo/pyclingo.cc` (search for `HeuristicType`)
- Configuration example: `examples/c/configuration.c`
- Existing heuristic patterns: `experiment/heuristic.lp` itself

## How experiments work

1. Read this file, `experiment/run.sh`, and `experiment/heuristic.lp` fully before making any changes.
2. Decide on **one focused change** — either a flag change in `run.sh` or a heuristic change in `heuristic.lp` (not both at once, so the effect is attributable).
3. Apply the change.
4. Run: `experiment/run.sh` and check the output in `experiment/out.txt`.
5. Compare `Time :` in the output to the previous best.
6. **If runtime improved** → commit with the structured message format below.
7. **If runtime did NOT improve** → `git checkout -- experiment/run.sh experiment/heuristic.lp` to revert only those files.
8. Update `experiment/scratchpad.md` with what you tried, what happened, and what to try next.
9. Repeat from step 2.

### Commit message format

Use this exact format so results can be parsed programmatically:

```
experiment: <short description>

time to solution: X.XX seconds (prev: Y.YY seconds)
```
