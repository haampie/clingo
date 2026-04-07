#!/bin/sh
# Profile spack solve cmake using macOS `sample` tool.
# Captures stack traces for 10 seconds and writes them to profile_output.txt.
# Open profile_output.txt to find hot functions and call stacks.

/tmp/x/bin/clingo --verbose=3 --stats=2 --configuration=tweety --opt-strategy=usc --heuristic=Domain --quiet=2,0,0 problem.lp &
PY_PID=$!
sample $PY_PID 10 -f profile_output.txt
