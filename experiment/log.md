# Optimization Log

## Baseline

ground=1.289s solve=0.932s total=3.572s (median of 3 runs)

## Changes

### 1. String equality via pointer comparison (instead of strcmp)

**Change:** In `libgringo/gringo/symbol.hh`, replaced `operator==(String, String)` and
`operator!=(String, String)` with pointer comparison (`a.c_str() == b.c_str()`) instead
of `strcmp`. Strings are interned (flyweight pattern), so equal strings share the same pointer.

**Result:** ground=1.291s solve=0.965s total=3.659s (median of 3 runs)
**Verdict:** Neutral — within noise (±0.5s). PGO likely already optimizes the strcmp calls.

### 2. Pre-reserve bodyIndex_ hash map in LogicProgram

**Change:** In `clasp/src/logic_program.cpp`, added `bodyIndex_.reserve(4096)` in `doStartProgram()` and `doUpdateProgram()` to pre-allocate the hash table before rules are added. The profiler showed 52 samples in `std::__hash_table::__do_rehash` during `addRule`, indicating repeated rehashing as the map grew from empty.

**Result:** ground=1.282s solve=0.934s total=3.622s (median of 3 runs)
**Verdict:** Neutral — ground improved only 0.007s, total +0.05s; both within noise.

## Profile Analysis Notes

Profile captured with `experiment/profile.sh` (10s `sample` run during a single `spack solve cmake`).
Total samples: 3907 (main thread) + 244 (clasp solver thread).

### Thread structure
- **Main thread**: Python + grounding
- **Solver thread** (244 samples): Clasp `SequentialSolve::doSolve` → `BasicSolve::State::solve`

### Hot C++ functions (flat profile, main thread)
| Samples | Function |
|---------|----------|
| 99 | `Gringo::FunctionTerm::match` (offsets 0, 136, 324) |
| 93 | `Gringo::Symbol::createFun` (offsets 0, 160, 568) |
| 31 | `Gringo::FunctionTerm::eval` (offsets 0, 180) |
| ~79 | `std::__stable_sort` for `MinimizeBuilder::CmpWeight` |
| 18 | `std::__introsort` for `Translator::translateMinimize` |
| 52 | `std::__hash_table::__do_rehash` in `LogicProgram::addRule` |
| 18 | `Clasp::Asp::LogicProgram::simplifyNormal` |
| 28 | `Gringo::ClaspAPIBackend::rule` |

### Key call chain (top-down, 905 samples = ground phase)
```
905 Program::ground
  497 Queue::process
    307 Instantiator::instantiate @ +5240
      190 Rule<true>::report @ +1548  → translate → addRule (rule output path)
       89 Rule<true>::report @ +756   → FunctionTerm::eval → createFun (term evaluation)
       23 Rule<true>::report @ +948   (other paths)
    55 Instantiator::instantiate @ +6056  (conjunction/aggregate report)
    46 Instantiator::instantiate @ +5268  (body aggregate path)
```

### What the hottest functions do

**FunctionTerm::match** (99 samples): Called during instantiation to check if a ground atom
matches a rule body pattern. For a predicate `f(X,Y)`, checks if an atom `f(a,b)` matches
by: (1) comparing Sig (name+arity via pointer+bit ops), (2) recursively matching each arg.
The atoms are already from the correct domain so the Sig check usually passes; time is in
the recursive argument matching and `x.args()` access.

**Symbol::createFun** (93 samples, includes ~32 in mutex region): Called from `FunctionTerm::eval`
to intern a ground function symbol. Takes `std::mutex` on a global `HashSet<Unique<MFun>>` to
look up or allocate the flyweight `Fun` object. Mutex is uncontended (single-threaded grounding)
but still costs ~20ns per call. With hundreds of thousands of calls, ~6ms from mutex alone.
Hash set lookup dominates.

**MinimizeBuilder sorts** (~79 samples): `MinimizeBuilder::build()` is called once per solve
to sort minimize literals by priority and weight. `CmpWeight::operator()` traverses a linked
list of LevelWeight entries per comparison — expensive for multi-level minimization (Spack uses
many optimization criteria). Sort is O(N log N * L) where L = number of levels.

### Ideas tried / evaluated
1. String pointer comparison — neutral, PGO already optimizes strcmp
2. bodyIndex_.reserve(4096) — neutral, rehashing is ~52ms total (below noise threshold)
3. Hoist x.args() in FunctionTerm::match — compiler likely already does with LTO+PGO
4. Cache Sig in FunctionTerm — risky (rename/project modify name), would need Sig update in all mutators
5. MinimizeBuilder CmpWeight optimization — sort is called once; savings maybe 30ms, below noise

### Why individual hotspots are hard to improve
The two hottest C++ functions (match + createFun) together account for ~192 samples = ~5% of
total profile = ~175ms. The noise floor is ±500ms. Even eliminating both entirely wouldn't
reliably beat the noise threshold. Need an algorithmic win affecting a larger fraction of total time.

### 3. MinimizeBuilder: stable_sort → sort

**Change:** In `clasp/src/minimize_constraint.cpp`, replaced three `std::stable_sort` calls
(in `prepareLevels`, `mergeLevels`, `createShared`) with `std::sort`. All three comparators
(CmpPrio, CmpLit, CmpWeight) are total orders; stability has no effect on correctness.
`std::sort` (introsort) avoids the temporary buffer allocation that `stable_sort` requires.

**Result:** ground=1.255s solve=0.965s total=3.607s (median of 3 runs)
**Verdict:** Neutral — ground improved 0.034s, total barely changed; both within noise.

### 4. Reuse thread_local ostringstream in ClaspAPIBackend::output

**Change:** In `libclingo/src/clingocontrol.cc`, replaced `std::ostringstream out` local
variables in `ClaspAPIBackend::output` (3 overloads) with a `thread_local` stream reset via
`str("")`+`clear()` between calls. Each call previously constructed/destructed an
`ostringstream` (initializing locale), called for every ground atom output to Clasp.
Profile showed 90 samples in `outputSymbols` → `showAtom` → `ClaspAPIBackend::output`.

**Result:** ground=1.232s solve=0.963s total=3.612s (median of 3 runs)
**Verdict:** Neutral — ground improved 57ms, total regressed 40ms; both within noise.

### Solve-phase hotspot: doEndProgram / prepareProgram / preprocessEq

Discovered from deeper profile analysis. The solve phase has a large preparation cost:

```
580 ClingoControl::solve → ClingoControl::prepare → ClaspFacade::prepare
  530 ProgramBuilder::endProgram
    398 LogicProgram::doEndProgram → prepareProgram
      ~309 Preprocessor::preprocessEq  (equivalence preprocessing)
        89 PrgBody::simplifyBody @ +1208 → LogicProgram::update (67 samples, hash map update)
           12 _nanov2_free, 6 operator new (bodyIndex_ node alloc/free)
        68 preprocessEq @ +2024/4292 (direct loop iteration / propagate)
        79 Preprocessor::addHeadToUpper (atom var assignment, head propagation)
        15 PrgBody::mergeHeads
      12 prepareOutputTable (stable_sort of pair<uint32, ConstString>)
```

`preprocessEq` (~309 samples ≈ ~282ms) runs before the CDNL solver starts, on the critical path.
It iterates over all bodies, simplifying them (replacing equivalent atoms, removing true/false lits),
recomputing body hashes, updating `bodyIndex_` (unordered_multimap). The main costs:
- `LogicProgram::update` does erase+insert on `bodyIndex_` (linked-list-based multimap), causing
  per-operation cache misses on the bucket array and heap alloc/free per node.
- `addHeadToUpper` assigns variables to atom heads and propagates; iterates over all supported bodies
  found via `classifyProgram`.

**Why this is hard to improve without major changes:**
- Changing `bodyIndex_` from `unordered_multimap` to flat open-addressing would be a deep refactor.
- `preprocessEq` must iterate all bodies — O(N) unavoidable.
- Even eliminating all of preprocessEq would give ~282ms savings (1.4x the threshold), but we can't
  skip it without breaking correctness.

### 5. stable_sort → sort in getSupportedBodies and prepareOutputTable

**Change:** In `clasp/src/logic_program.cpp`:
- `getSupportedBodies(true)`: sort `initialSupp_` by body size — stability not needed since
  only order within same-size bodies changes, and `preprocessEq` is a fixed-point iteration.
- `prepareOutputTable()`: sort `show_` by atom ID (`select1st<ShowPair>()`) — IDs are unique,
  so this is a total order; stability is not required.

**Result:** ground=1.286s solve=0.965s total=3.703s (median of 3 runs)
**Verdict:** Neutral — ground +0.003s, solve +0.033s, total +0.131s; all within noise.

### 6. Replace bodyIndex_ unordered_multimap with flat hash table

**Change:** In `clasp/clasp/logic_program.h`, added a `FlatMultiMap` class that stores entries
in a contiguous `std::vector<Node>` with bucket chaining via indices (no per-entry heap
allocation). Replaced `typedef unordered_multimap<uint32, uint32> IndexMap` with
`typedef FlatMultiMap IndexMap`. The class provides the same API (`insert`, `equal_range`,
`find`, `erase`, `clear`) and is a drop-in replacement. Key design: power-of-2 bucket count
with bitmask modulo, free-list recycling of erased nodes, O(bucket_count) clear instead of
O(N) destructor calls.

**Result:** ground=1.079s solve=0.791s total=3.269s (median of 3 runs)
**Verdict:** Improvement — ground -0.210s (16.3%), solve -0.141s (15.1%), total -0.303s (8.5%).
First change to break the ±0.5s noise floor on ground+solve combined (-0.351s).

### Promising directions not yet tried
- `FunctionTerm::eval` cache: pre-reserve `cache` vector in constructor to avoid first-eval allocation
- `translateMinimize` comparator: cache `data.tuple(...)` result per element before sorting instead of looking up on every comparison
- Look at inlined `toGround()` (estimated ~227 samples from `ClingoControl::ground` direct offsets)
