# Experiment Log

## Current best: ~17.69s (range 17.67-17.72s)
Config: `--configuration=tweety --opt-strategy=usc,2 --opt-heuristic=model --del-max=650000 --trans-ext=no --backprop --nant --sign-def=neg --del-glue=5,0 --otfs=2 --score-res=multiset --heuristic=Domain --parallel-mode=2`

## Problem characteristics
- Total time: ~19.686s baseline
- Reading: 9.877s, Preprocessing: 5.573s, Solving: 4.24s
- Most time is in reading/preprocessing (~15.45s), not solving (4.24s)
- Models: 8 found, Optimum: yes
- Conflicts: 82 (only 57 analyzed), Restarts: 0
- Choices: 4770 (Domain: 4654 — nearly all domain choices)
- Variables: 1,276,720 | Constraints: 5,089,256
- Tight: No (SCCs: 7598)


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
| 103 | `--del-max=700000` | 18.337 | — | within timing variance of 750k, reverted bad commit |
| 104 | `--del-cfl=no` (disable conflict-based deletion) | 18.333-18.379 | ~ | within timing variance |
| 105 | `--del-cfl=+,1000,50,10` | 18.364 | ~ | within timing variance |
| 106 | `--vsids-acids` (ACIDS scheme) | 19.465 | +1.23s | much worse |
| 107 | `--score-res=set` | 18.347 | ~ | within timing variance |
| 108 | `--score-res=multiset` | 18.141-18.146 | -0.10s ✓ | **committed** new best ~18.14s — solving time dropped 3.72→3.48s |
| 109 | `--score-res=min` | 18.313 | +0.17s | worse than multiset |
| 110 | `--score-other=loop` | 18.016-18.140 | ~ | within variance (baseline also 17.99-18.08s with score-res=multiset) |
| 111 | `--contraction=250` | 18.236 | +0.19s | worse |
| 112 | `--score-other=no` | 18.332 | +0.28s | worse |
| 113 | heuristic: add `[120, level]` + `[-1, sign]` for `attr("node_platform")` and `attr("node_os")` | 18.099 | ~ | within variance, reverted |
| 114 | heuristic: `[4, factor]` on version atoms | (interrupted) | — | retry |
| 115 | `--restart-on-model` | 18.057 / 18.011 | ~ | within variance, reverted |
| 116 | `--lookahead=atom,1` | 22.996 | +4.95s | much worse, reverted |
| 117 | `true` modifier for virtual_node c/cxx/libc — interrupted mid-run | — | — | agent stopped, incomplete |
| 118 | heuristic: `[4, factor]` on version atoms | 18.118 | ~ | within variance, reverted |
| 119 | heuristic: `true` modifier `[130, true]` for c/cxx/libc virtual nodes | 18.652 | +0.50s | worse, reverted |
| 120 | `--contraction=150` (below tweety default 250) | 18.119 | ~ | within variance, reverted |
| 121 | `--contraction=100` | 18.026 / 18.085 | ~ | within variance on re-run, reverted |
| 122 | `--del-max=900000` | 18.299 | +0.25s | worse, reverted |
| 123 | heuristic: add `[120, level]` + `[-1, sign]` for `attr("node_platform")` and `attr("node_os")` | 17.967/18.015/17.987 | -0.06s ✓ | **committed** new best ~17.99s, solving time 3.37s (was 3.48s) |
| 124 | `--dom-mod=false,show` | 17.988 | ~ | within variance, reverted |
| 125 | `--restarts=no` (solver has 0 restarts anyway) | 18.166 | +0.18s | worse, reverted |
| 126 | `--forget-on-restart=0` | error | — | unknown option, reverted |
| 127 | `--update-act` (LBD-based activity bumping) | 18.003 | ~ | within variance, reverted |
| 128 | `--vsids-progress=94,2` (slightly higher decay than tweety's 92,2) | 18.026 | ~ | within variance, reverted |
| 129 | `--opt-usc-shrink=bin` | 21.341 | +3.35s | much worse (solving 6.71s vs 3.37s), reverted |
| 130 | heuristic: add conditional `[1@2, sign]` hints for allowed_platform and os(OS,0) | 18.164 | +0.17s | worse, reverted |
| 131 | `--block-restarts=100` (glucose-style blocking) | 18.079 | ~ | within variance, reverted |
| 132 | heuristic: add `[600, init]` for node_platform and node_os | 18.452 | +0.46s | worse (Unsat 0.26s vs 0.01s), reverted |
| 133 | `--del-glue=5,1` (keep 1 recent learnt per level) | 18.028 | ~ | within variance, reverted |
| 134 | `--del-max=650000` | 17.964/18.000/17.997 | -0.01s ✓ | **committed** new best ~17.99s, solving 3.35s |
| 135 | `--del-max=600000` | 18.012 | ~ | within variance, reverted |
| 136 | heuristic: lower node_platform/node_os level to 90 (from 120) | 17.991 | ~ | within variance, reverted |
| 137 | heuristic: `[4, factor]` on virtual_node atoms | 17.913/17.918 | -0.07s ✓ | **committed** new best ~17.92s |
| 138 | heuristic: raise virtual_node factor to `[8, factor]` | 17.936 | ~ | within variance, reverted |
| 139 | heuristic: `[4, factor]` on variant_value atoms | 17.923 | ~ | within variance, reverted |
| 140 | `--del-max=680000` | 18.015 | ~ | within variance, reverted |
| 141 | `--del-max=620000` | 17.980 | ~ | within variance, reverted |
| 142 | heuristic: version sign priority `@3` (was `@2`) | 18.018 | ~ | within variance, reverted |
| 143 | heuristic: `[4, factor]` on virtual_on_edge atoms | 17.869/17.823 | -0.07s ✓ | **committed** new best ~17.85s, solving 3.24s (was 3.35s) |
| 144 | heuristic: raise virtual_on_edge factor to `[8, factor]` | 17.915 | +0.07s | slightly worse, reverted |
| 145 | heuristic: `[4, factor]` on node_target atoms | 17.833/17.832 | ~ | within variance, reverted |
| 146 | heuristic: `[4, factor]` on version atoms (retried with new state) | 17.884 | +0.03s | slightly worse, reverted |
| 147 | `--del-max=550000` | 17.865 | ~ | within variance, reverted |
| 148 | heuristic: raise all `[120, level]` → `[130, level]` | 17.891 | +0.04s | slightly worse, reverted |
| 149 | `--del-glue=4,0` (retried with new config) | 17.872 | ~ | within variance, reverted |
| 150 | heuristic: raise node factor from `[4, factor]` to `[6, factor]` | 17.880 | ~ | within variance, reverted |
| 151 | heuristic: `[800, init]` on virtual_on_edge | 21.247 | +3.40s | catastrophically worse (1st model 4.30s), reverted |
| 152 | heuristic: `[-1, sign]` on virtual_on_edge | 17.883 | ~ | within variance, reverted |
| 153 | `--parallel-mode=2` | 17.715/17.669 | -0.16s ✓ | **committed** new best ~17.69s, solving 3.10s (was 3.24s) |
| 154 | `--parallel-mode=4` | 18.092 | +0.40s | worse — more threads hurt, overhead increases |
| 155 | `--parallel-mode=2,split` | 17.712 | ~ | within variance; warns "Selected strategies imply Mode=compete" — same as parallel-mode=2, reverted |
| 156 | `--parallel-mode=4,split` | 18.166 | +0.48s | worse; also falls back to compete mode, reverted |
