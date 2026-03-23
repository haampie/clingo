# Next ideas

- Try del-max values 650k, 720k with current full config
- `--lookahead=atom` or `--lookahead=body`
- `--forget-on-restart` / `--partial-check` / `--usc-core-sched`
- Heuristic: add `#heuristic` for `attr("node_platform")`, `attr("node_os")`, `attr("compiler_version")` atoms (currently no guidance — see program.md)
- Heuristic: try `true`/`false` modifiers instead of separate `level` + `sign` (see program.md for semantics)
- Heuristic: `factor` modifier on version/variant atoms to boost VSIDS re-selection after conflicts
- Heuristic: conditional body directives — hint version atoms only once the parent `attr("node")` is decided
- Run multiple times to confirm results within timing variance (~0.1–0.2s)
