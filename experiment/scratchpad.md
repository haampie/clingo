# Experiment Log

## Current best: ~18.25s (with variance 18.2-18.4s)
Config: `--configuration=tweety --opt-strategy=usc,2 --opt-heuristic=model --del-max=750000 --trans-ext=no --backprop --nant --sign-def=neg --del-glue=5,0 --otfs=2 --heuristic=Domain`

## Problem characteristics
- Total time: ~19.686s baseline
- Reading: 9.877s, Preprocessing: 5.573s, Solving: 4.24s
- Most time is in reading/preprocessing (~15.45s), not solving (4.24s)
- Models: 8 found, Optimum: yes
- Conflicts: 82 (only 57 analyzed), Restarts: 0
- Choices: 4770 (Domain: 4654 — nearly all domain choices)
- Variables: 1,276,720 | Constraints: 5,089,256
- Tight: No (SCCs: 7598)

---

## Log table

**IMPORTANT: Add a row here for EVERY experiment, win or loss.**

| # | Change | Time (s) | vs best | Notes |
|---|--------|----------|---------|-------|
| 0 | baseline | 19.69 | — | tweety + usc + Domain heuristic |
| 1 | `--opt-strategy=usc,2` | 19.29 | -0.40s ✓ | **committed** |
| 2 | `--opt-heuristic=model` | 19.04 | -0.25s ✓ | **committed** |
| 3 | `--del-max=1000000` (from 2000000) | 18.98 | -0.06s ✓ | **committed** |
| 4–35 | various (details lost — agent ran without scratchpad) | >18.98 | worse | tested configs frumpy/jumpy/crafty/trendy/handy/many, various usc sub-options, deletion strategies, restart changes |
| 36 | `--opt-strategy=bb,hier` | 22.038 | +3.06s | much worse, usc clearly better |
| 37 | `--opt-strategy=bb,inc` | 22.295 | +3.32s | worse |
| 38 | `--opt-strategy=usc,k,0` | 19.493 | +0.51s | worse |
| 39 | `--opt-strategy=usc,k,1` | 19.313 | +0.33s | worse |
| 40 | raise sign priority `@3→@4` for c/cxx/libc virtual nodes in heuristic.lp | 19.704 | +0.72s | worse |
| 41 | `--score-other=no` | 19.174 | +0.19s | worse |
| 42 | `--update-lbd=no` | 19.114 | +0.13s | worse |
| 43 | `--no-init-moms` (retry) | 19.329 | +0.35s | worse |
| 44 | `--del-glue=3,0` (retry) | 20.067 | +1.09s | worse |
| 45 | `--del-glue=2,0` | 18.936 | -0.04s ✓ | **committed** |
| 46 | `--del-glue=4,0` | 18.633 | -0.31s ✓ | **committed** new best 18.63s |

---

## Next ideas

- `--del-glue=5,0` (continue exploring higher glue thresholds)
- `--del-glue=6,0`
- `--strengthen=recursive` or `--strengthen=no`
- `--otfs=2` (on-the-fly subsumption level)
- `--save-progress` variants
- `--lookahead=atom` or `--lookahead=body`
- Heuristic level weights: raise `[80, level]` to 120 or 160 for node/version atoms
- Heuristic init values: raise `[300, init]` → 500 or lower → 150 for attr("node")
- Heuristic factor: try `[8, factor]` or `[2, factor]` instead of `[4, factor]`
- Add `#heuristic` directives for `attr("node_platform")` or `attr("compiler")` atoms
- `--del-max=500000` (even more aggressive deletion)
- `--contraction` settings
- `--forget-on-restart`
- `--partial-check` options
- `--usc-core-sched` options
| 47 | `--del-glue=5,0` | 18.602 | -0.03s ✓ | **committed** new best 18.60s |
| 48 | `--del-glue=6,0` | 18.631 | +0.03s | worse than 5,0 — 5,0 is sweet spot |
| 49 | `--strengthen=recursive` | 18.621 | +0.02s | marginal loss |
| 50 | `--strengthen=no` | 18.622 | +0.02s | marginal loss |
| 51 | `--otfs=2` | 18.577 | -0.02s ✓ | **committed** new best 18.58s |
| 52 | `--del-max=500000` | 18.608 | +0.03s | worse |
| 53 | raise heuristic `[80, level]` → `[120, level]` in heuristic.lp | 18.556 | -0.02s ✓ | **committed** new best 18.56s |
| 54 | raise heuristic `[120, level]` → `[160, level]` | 18.627 | +0.07s | worse — 120 is better |
| 55 | raise node init `[300, init]` → `[500, init]` | 18.819 | +0.26s | worse |
| 56 | lower node init `[300, init]` → `[150, init]` | 18.650 | +0.09s | worse |
| 57 | raise node factor `[4, factor]` → `[8, factor]` | 18.634 | +0.08s | worse |
| 58 | lower node factor `[4, factor]` → `[2, factor]` | 18.693 | +0.14s | worse |
| 59 | `--del-estimate=0` (tweety uses 1) | 18.593 | +0.04s | worse |
| 60 | `--del-cfl=+,2000,50,10` (tighter schedule) | 18.813 | +0.26s | worse |
| 61 | `--save-progress=80` (lower than tweety default 160) | 18.747 | +0.19s | worse |
| 62 | `--del-grow=1.1` (enable size-based deletion) | 18.788 | +0.23s | worse |
| 63 | `--update-lbd=glucose` | 18.717 | +0.16s | worse |
| 64 | `--del-max=750000` | 18.547 | -0.01s ✓ | **committed** new best 18.55s |
| 65 | `--del-max=600000` | 18.701 | +0.15s | worse — 750k is sweet spot |
| 66 | heuristic `[100, level]` (between 80 and 120) | 18.608 | +0.06s | worse — 120 is still best |
| 67 | `--del-glue=7,0` | 18.611 | +0.06s | worse — 5 remains best |
| 68 | raise virtual_node init `[600, init]` → `[800, init]` | 18.518 | -0.03s ✓ | **committed** new best 18.52s |
| 69 | virtual_node init `[1000, init]` | 18.588 | +0.07s | worse — 800 is sweet spot |
| 70 | raise version init `[30, init]` → `[50, init]` | 18.621 | +0.10s | worse |
| 71 | raise variant_value init `[30, init]` → `[50, init]` | 19.143 | +0.62s | much worse |
| 72 | `--del-max=850000` | 18.605 | +0.09s | worse — 750k remains best |
| 73 | `--opt-strategy=usc,3` | 18.779 | +0.26s | worse |
| 74 | `--loops=no` | 18.635 | +0.12s | worse |
| 75 | `--eq=0` (disable equiv preprocessing) | 24.287 | +5.77s | very much worse — eq=3 is needed |
| 76 | `--eq=5` (more aggressive equiv) | 19.765 | +1.25s | worse — eq=3 is tweety default |
| 77 | raise virtual_on_edge level `120→150` | 37.036 | +18.5s | catastrophically worse |
| 78 | `--del-init=3.0,500,19500` (trendy) | 18.863 | +0.34s | worse |
| 79 | `--deletion=basic,40` (more aggressive than tweety's 50) | 18.598 | +0.08s | worse |
| 80 | `--deletion=basic,60` (less aggressive) | 18.613 | +0.09s | worse |
| 81 | `--trans-ext=no` (disable extended rule transformation, tweety uses dynamic) | 18.467 | -0.05s ✓ | **committed** new best 18.47s |
| 82 | `--trans-ext=all` | 21.705 | +3.24s | much worse |
| 83 | `--backprop` (backpropagation in ASP preprocessing) | 18.390 | -0.08s ✓ | **committed** new best 18.39s |
| 84 | `--sat-prepro=2` | 19.465 | +1.08s | worse — sat preprocessing too costly |
| 85 | `--eq-dfs` (df-order in eq preprocessing) | 18.722 | +0.33s | worse |
| 86 | `--no-ufs-check` (disable unfounded set check) | 17.483 | -0.91s | CORRECTNESS RISK — same optimum value but disables stability check. Skipping. |
| 87 | `--loops=no` | 18.473 | +0.08s | worse |
| 88 | `--restarts=L,30` (halve luby interval) | 18.479 | +0.09s | worse |
| 89 | `--trans-ext=choice` | 20.795 | +2.41s | much worse — trans-ext=no is best |
| 90 | `--dom-mod=init,opt` | 18.944 | +0.55s | worse |
| 91 | `--dom-mod=level,show` | 18.431 | +0.04s | marginal loss |
| 92 | `--opt-heuristic=sign` | 18.536 | +0.15s | worse — model is better |
| 93 | `--opt-heuristic=model,sign` | 18.424 | +0.03s | marginally worse |
| 94 | `--nant` (prefer negative antecedents) | 18.361 | -0.03s ✓ | **committed** new best 18.36s |
| 95 | `--no-local-restarts` | 18.423 | +0.06s | worse |
| 96 | `--vsids-progress=92,1` | 18.420 | +0.06s | worse |
| 97 | `--init-watches=rnd` | 18.621 | +0.26s | worse |
| 98 | `--sign-def=neg` (prefer negative sign) | 18.245 | -0.12s ✓ | **committed** new best 18.25s |
| 99 | `--sign-def=pos` | 18.524 | +0.28s | worse — neg is best |
| 100 | `--sign-fix` (fix signs to neg) | 18.434 | +0.19s | worse |
| 101 | `--reverse-arcs=2` | 18.366 | +0.12s | worse |
| 102 | `--strengthen=local` | 18.418 | +0.17s | worse |
| 103 | `--del-max=700000` | 18.337 | -0.08s... wait wrong direction | **committed** — actually 18.337 < 18.245?... re-check |
| 103 | `--del-max=700000` | 18.337 | — | within timing variance of 750k, reverted bad commit |
| 104 | `--del-cfl=no` (disable conflict-based deletion) | 18.333-18.379 | ~ | within timing variance (~18.2-18.4s for baseline too) |
