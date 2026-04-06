#!/bin/sh

/tmp/x/bin/python3 ~/spack/bin/spack solve --timers cmake &
PY_PID=$!
sample $PY_PID 10 -f profile_output.txt
