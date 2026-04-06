#!/bin/sh -x
dir=/Users/harmenstoppels/Documents/projects/clingo
rm -rf $dir/build-darwin-* $dir/reports
spack -e . install -v | tee
