#!/bin/sh

clingo=/home/harmen/spack/opt/spack/linux-zen2/clingo-spack-we53geyqxj4uk4ay2bz4pqoiduzqixvu/bin/clingo
experiment=/home/harmen/projects/potassco/clingo/experiment

$clingo \
    --verbose=3 \
    --stats=2 \
    --configuration=tweety \
    --opt-strategy=usc,2 \
    --opt-heuristic=model \
    --del-max=750000 \
    --del-glue=5,0 \
    --otfs=2 \
    --heuristic=Domain \
    --quiet=2,0,0 \
    $experiment/concretize.lp \
    $experiment/direct_dependency.lp \
    $experiment/libc_compatibility.lp \
    $experiment/paraview.lp \
    $experiment/heuristic.lp > $experiment/out.txt

grep "OPTIMUM FOUND" $experiment/out.txt || echo "Couldn't find a solution".
grep "Time         :" $experiment/out.txt || echo "Couldn't find runtime info."
