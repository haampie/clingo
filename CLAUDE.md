# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Clingo is an Answer Set Programming (ASP) grounder and solver, part of the [Potassco](https://potassco.org) project. It takes logic programs and computes answer sets representing solutions to combinatorial problems.

The pipeline: **ASP logic program → [libgringo] → ground program → [clasp solver] → answer sets**

## Architecture

### Core Libraries

- **libgringo** — Parser and grounder; transforms logic programs into ground (propositional) programs. Contains `input/` (parsing), `ground/` (grounding), `output/` (back-ends).
- **clasp** — ASP solver (git submodule from potassco/clasp). Takes ground programs and computes answer sets.
- **libclingo** — Glues libgringo and clasp together; provides the public C and C++ APIs (`clingo.h`, `clingo.hh`). The main `Control` object lives here (`libclingo/src/control.cc`, `libclingo/src/clingocontrol.cc`).
- **libreify** — Reification: transforms programs into a meta-level representation.

### Language Bindings

- **libpyclingo** — Python bindings via native C extension (`libpyclingo/pyclingo.cc`, ~380KB). Python package lives in `libpyclingo/clingo/`. Type stubs in `libpyclingo/clingo/*.pyi`.
- **libpyclingo_cffi** — Alternative Python bindings using CFFI (useful for PyPy).
- **libluaclingo** — Lua scripting bindings.

### Applications

- **app/clingo** — Main command-line tool (thin wrapper calling `clingo_main_()` from libclingo).
- **app/gringo** — Grounding-only frontend.
- **app/reify** — Reification frontend.

## CLI Options

The clingo CLI options are defined in `libclingo/src/clingo_app.cc` (inherits from `Clasp::Cli::ClaspAppBase`, so clasp solver options are also available).

Key options:
- `--mode={clingo|clasp|gringo}` — run mode (default: clingo)
- `--const,-c <id>=<term>` — replace constant definitions in the program
- `--output,-o {intermediate|text|reify|smodels}` — output format (gringo mode)
- `--warn,-W <warn>` — enable/disable warnings (none, all, [no-]atom-undefined, [no-]file-included, etc.)
- `--text` — print plain text format (implies gringo mode)

Solver parameters (from clasp) are exposed through the configuration system — see below.

## Parameter Tuning

Solver configuration uses a **hierarchical dot-notation** system. Key configuration paths:

- `solve.models` — number of models to compute (0 = all)
- `solver[0].heuristic` — atom selection heuristic (e.g., `berkmin`, `vsids`, `dom`)

**C API** (`examples/c/configuration.c`):
```c
clingo_control_configuration(ctl, &conf);
clingo_configuration_root(conf, &root_key);
clingo_configuration_map_at(conf, root_key, "solve.models", &sub_key);
clingo_configuration_value_set(conf, sub_key, "0");
```

**Python API**:
```python
ctl.configuration.solve.models = 0
ctl.configuration.solver[0].heuristic = "berkmin"
```

The full set of available configuration keys comes from clasp (submodule at `clasp/`). To explore all available options and their values at runtime, iterate the configuration tree via the API — the configuration object acts as both a map and an array depending on the key.

## Examples

Working examples are in `examples/`:
- `examples/c/` — C API usage (control, configuration, symbolic atoms, async solving)
- `examples/cc/` — C++ API usage
- `examples/clingo/` — Python/Lua examples (37+ scenarios covering propagators, heuristics, etc.)
