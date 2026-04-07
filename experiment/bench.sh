#!/bin/sh
# Benchmark clingo on problem.lp, report median ground/solve/total times.
# Output: a single compact line suitable for appending to log.md.

set -eu

RUNS=3
CLINGO=/tmp/x/bin/clingo
PROBLEM="$(dirname "$0")/problem.lp"

ground_times=""
solve_times=""
total_times=""

for i in $(seq 1 $RUNS); do
    output=$($CLINGO --stats=2 --configuration=tweety --opt-strategy=usc --heuristic=Domain --quiet=2,0,0 "$PROBLEM" 2>&1 || true)
    # Parse "Time         : 1.234s (Solving: 0.567s ...)"
    timeline=$(echo "$output" | grep "^Time " | head -1)
    total=$(echo "$timeline" | awk '{print $3+0}')
    solve=$(echo "$timeline" | sed 's/.*Solving: \([0-9.]*\)s.*/\1/')
    ground=$(echo "$total $solve" | awk '{printf "%.3f", $1 - $2}')
    ground_times="$ground_times $ground"
    solve_times="$solve_times $solve"
    total_times="$total_times $total"
    printf "  run %d: ground=%.3fs solve=%.3fs total=%.3fs\n" "$i" "$ground" "$solve" "$total"
done

median() {
    echo "$@" | tr ' ' '\n' | sort -n | awk 'NR=='"$(( (RUNS+1)/2 ))"
}

mg=$(median $ground_times)
ms=$(median $solve_times)
mt=$(median $total_times)

result="ground=${mg}s solve=${ms}s total=${mt}s (median of $RUNS runs)"
echo ""
echo "Result: $result"
