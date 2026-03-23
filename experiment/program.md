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

**Scratchpad** (always update by appending):
- `experiment/scratchpad.md` — append-only log table of every experiment. Each new row goes at the end of the file. Never edit earlier rows.
- `experiment/next_ideas.md` — ideas to try next. Edit freely: add new ideas, strike through completed ones (`~~item~~`).

The log table format (rows are appended to the end of `scratchpad.md`):

| # | Change | Time (s) | vs best | Notes |
|---|--------|----------|---------|-------|
| 1 | baseline | 19.69 | — | tweety + usc + Domain |
| 2 | `--configuration=crafty` | 21.3 | +1.6s | worse, reverted |
| … | … | … | … | … |

**Reference material** — read freely to understand solver options and heuristic semantics:
- Clingo/clasp CLI option definitions: `libclingo/src/clingo_app.cc`
- `#heuristic` directive semantics: `libpyclingo/pyclingo.cc` (search for `HeuristicType`)
- Configuration example: `examples/c/configuration.c`
- Existing heuristic patterns: `experiment/heuristic.lp` itself

## Heuristic directive reference

### Syntax (from `libgringo/src/input/nongroundgrammar.yy`)

```
#heuristic atom : body. [bias@priority, modifier]
#heuristic atom : body. [bias, modifier]   % priority defaults to 0
#heuristic atom.                [bias, modifier]   % unconditional
```

- **atom** — any ground atom (can have variables if body grounds them)
- **bias** — an integer (meaning depends on modifier)
- **priority** — unsigned int; when multiple directives apply to the same atom and modifier, higher priority wins
- **body** (optional) — a condition; the directive only fires when the condition holds, making it *dynamic* during search

### Modifiers (from `libclingo/clingo.h` and `libclingo/clingo.hh`)

| Modifier | Bias meaning | Effect |
|----------|-------------|--------|
| `level`  | integer     | Set the atom's decision *level priority* — higher means decided earlier in search. Atoms with the same level compete on VSIDS score. This is the main ordering lever. |
| `sign`   | +1 = prefer true, −1 = prefer false | Set the preferred polarity when the atom is selected. Does not change *when* the atom is selected. |
| `init`   | integer     | Set the atom's initial VSIDS score (before any conflicts). Larger = selected earlier within the same level. |
| `factor` | integer     | Multiply the VSIDS score bump by this factor each time the atom is involved in a conflict. `[2, factor]` makes the atom score rise twice as fast. `[0, factor]` effectively freezes it. |
| `true`   | integer     | **Shorthand**: sets level (= bias) AND forces *positive* sign in one directive. Equivalent to separate `level` + `[1, sign]` at the same priority. |
| `false`  | integer     | **Shorthand**: sets level (= bias) AND forces *negative* sign in one directive. Equivalent to separate `level` + `[-1, sign]` at the same priority. |

### Key things the current heuristic.lp does NOT yet use

1. **`true`/`false` modifiers** — these commit both ordering and sign atomically, which can be stronger than separate `level` + `sign` directives when you know an atom should definitely be decided one way. Example:
   ```
   % Decide attr("node", PackageNode) true before anything else
   #heuristic attr("node", PackageNode). [80, true]
   ```

2. **`factor` modifier for critical atoms** — currently only `[4, factor]` is used for `attr("node")`. The `factor` modifier changes how fast a variable's VSIDS score grows when it appears in conflicts; a higher factor makes the solver *re-select* that atom sooner after a conflict. Could try boosting it for version or variant_value atoms which matter for the objective.

3. **Conditional (dynamic) heuristics** — body conditions let you fire directives only in certain states. For example, once a package node is chosen, immediately hint at its preferred version:
   ```
   % When a node is chosen, immediately prefer version 0 (highest ranked)
   #heuristic attr("version", node(I,P), V) : attr("node", node(I,P)), pkg_fact(P, version_declared(V,0)). [1@3, true]
   ```
   This is already partly done but the priority/modifier combinations can vary.

4. **Negative body conditions** — directives can fire when something is *not* true:
   ```
   #heuristic attr("node", node(0, Pkg)) : not virtual(Pkg). [1@2, true]
   ```

### `--dom-mod` flag

Applies a default heuristic modification to *all* domain atoms (those appearing in `#heuristic` directives) without requiring explicit directives for each. Useful for setting a global default sign or ordering preference.

```
--dom-mod=<mod>[,<pick>]
```

- `<mod>`: `level` | `pos` | `true` | `neg` | `false` | `init` | `factor`
- `<pick>` (subset to apply to): `all` | `scc` | `hcc` | `disj` | `opt` | `show`

Examples worth trying:
- `--dom-mod=false,opt` — prefer false (not-selected) for atoms in minimization criteria
- `--dom-mod=neg,show` — prefer negative for output atoms
- The trendy config uses `--heuristic=domain --dom-mod=neg,opt` with bb strategy (source: `clasp/clasp/cli/clasp_cli_configs.inl`)

## Understanding the problem structure (concretize.lp)

`experiment/concretize.lp` is 2356 lines — you don't need to read all of it, but understanding its key atoms and optimization criteria helps you write better `#heuristic` directives. Here's what matters:

### Choice atoms (the decisions the solver makes)

These are the atoms the heuristic should guide — confirmed by reading lines 16–17 and the existing `heuristic.lp`:

| Atom | What it means |
|------|--------------|
| `attr("node", node(ID, Package))` | Whether package `Package` (with duplicate ID `ID`) is included |
| `attr("virtual_node", node(ID, Virtual))` | Whether virtual package `Virtual` is satisfied |
| `attr("version", PackageNode, Version)` | Which version is chosen for a package |
| `attr("variant_value", PackageNode, Variant, Value)` | Which value a variant takes |
| `attr("node_target", PackageNode, Target)` | Which build target (e.g., `x86_64`) |
| `virtual_on_edge(PackageNode, ProviderNode, Virtual, Type)` | Which concrete package satisfies a virtual dep |

### Optimization criteria (from lines 2082–2356)

The solver minimizes these in priority order (higher = more important). Knowing this tells you *which atoms matter most* for reaching the optimum quickly:

| Priority | Criterion |
|----------|-----------|
| @1000 | Errors (hard — avoid at all cost) |
| @310 | Requirement weight |
| @110 | Number of packages to build (prefer reuse) |
| @100 | Number of duplicate nodes |
| @90 | Build unification set IDs |
| @73 | Deprecated versions used |
| @70 | Version badness (root packages) |
| @65 | Variant penalty (root packages) |
| @55 | Non-default variant values (roots) |
| @48 | Preferred compilers / language providers |
| @40 | Variant penalty (non-roots) |
| … | (more criteria below @40) |

### Heuristic strategy implications

- **`attr("node")` decisions are gated**: a package's version/variant atoms are only relevant if the package is included. So hinting `attr("node")` to be decided first (high `level`) before version/variant is correct.
- **`attr("version")` directly affects @70 objective**: getting versions right quickly (via strong `sign` hints toward `version_declared(..., 0)`) reduces backtracking on the high-priority objectives.
- **`virtual_node` with node ID 0 is preferred** (@100 minimizes IDs): `[−1, sign]` on virtual nodes (prefer false = not included unless needed) is already in `heuristic.lp` and is correct.
- **Compilers matter at @48**: `virtual_on_edge` for language virtuals (`c`, `cxx`, `libc`) has high impact on the objective — the existing heuristic already gives these high priority.
- **Untried**: `attr("node_platform")`, `attr("node_os")`, `attr("compiler_version")` atoms are not currently in `heuristic.lp` at all. These may be low-hanging fruit since the solver currently has no guidance on them.

### Suggested reading strategy

If you want to understand a specific atom better, search for it in `concretize.lp`:
```sh
grep -n 'attr("node_platform"' experiment/concretize.lp | head -20
grep -n 'attr("compiler' experiment/concretize.lp | head -20
```

## How experiments work

1. Read this file, `experiment/run.sh`, and `experiment/heuristic.lp` fully before making any changes.
2. Decide on **one focused change** — either a flag change in `run.sh` or a heuristic change in `heuristic.lp` (not both at once, so the effect is attributable).
3. Apply the change.
4. Run: `experiment/run.sh` and check the output in `experiment/out.txt`.
5. Compare `Time :` in the output to the previous best.
6. **If runtime improved** → commit with the structured message format below.
7. **If runtime did NOT improve** → `git checkout -- experiment/run.sh experiment/heuristic.lp` to revert only those files.
8. **Always** append a new row to `experiment/scratchpad.md` (including failures). Also update `experiment/next_ideas.md`: strike through the idea you just tried, add any new ideas that came up.
9. Repeat from step 2.

### Commit message format

Use this exact format so results can be parsed programmatically:

```
experiment: <short description>

time to solution: X.XX seconds (prev: Y.YY seconds)
```
