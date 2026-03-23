# Clingo Solver Parameter Optimization for paraview.lp

## Problem characteristics
- Total time: ~19.686s
- Reading: 9.877s, Preprocessing: 5.573s, Solving: 4.24s
- Most time is in reading/preprocessing (~15.45s), not solving (4.24s)!
- Models: 8 found, Optimum: yes
- Conflicts: 82 (only 57 analyzed), Restarts: 0
- Choices: 4770 (Domain: 4654 — nearly all domain choices)
- Variables: 1,276,720 | Constraints: 5,089,256
- Tight: No (SCCs: 7598)
- Current flags: `--configuration=tweety --opt-strategy=usc --heuristic=Domain --verbose=3 --stats=2 --quiet=2,0,0`

## Key insight
Since 78% of the time is reading/preprocessing, reducing verbose/stats output may help marginally,
but the main wins will be from faster solving or reducing preprocessing overhead.

The USC strategy with Domain heuristic is already well-tuned.
USC finds optimal by proving cores are unsat — low conflicts (82) suggests it's working efficiently.

## Experiments

### Experiment 1 — Baseline
- Config: `--configuration=tweety --opt-strategy=usc --heuristic=Domain`
- Time: 19.686s
- Result: BASELINE

## Ideas to try (in order)
1. `--configuration=crafty` — may handle structured problems better
2. `--configuration=trendy` — different restart policy
3. `--opt-strategy=usc,1` — usc with k=1 (more aggressive core shrinking)
4. `--opt-strategy=usc,2` — usc with k=2
5. `--opt-strategy=usc,ot` — usc with optimum tracking
6. Increase heuristic init weights
7. `--configuration=handy`
8. Remove verbose/stats to reduce overhead
9. `--dom-mod` options
10. bb strategy with strong heuristic
