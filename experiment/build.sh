#!/bin/sh -x
spack clean --stage
dir=/Users/harmenstoppels/Documents/projects/clingo
rm -rf $dir/build-darwin-* $dir/reports
spack -e $dir/experiment install -v | tee
