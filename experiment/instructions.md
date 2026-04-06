Your task is to optimize the clingo runtime as follows:

1. Make a SINGLE change to the clingo source code.
2. Run the build `experiment/build.sh`
3. Run the benchmark `experiment/bench.sh`
4. ALWAYS append the change and perf diff in `experiment/log.md`, even if worse
   results -- this is important, so we don not loose track of what's tried but
   was not successful.
5. If perf improved: commit changes.
6. If perf regressed: reset changes.
7. Go to step 1
