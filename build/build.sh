#!/bin/sh
mkdir -p tree/gcc
c=
for d in "binutils/*" "gcc/*" mpc mpfr gmp isl cloog ; do
	c+=" ../git/$d"
done
eval rsync -rv $c tree/gcc
