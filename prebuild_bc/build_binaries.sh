#!/bin/bash

source env.config

VCLANG=${VAN}/clang
MOPT=${MOD}/opt

BIN=`pwd`/bin
BCS=`pwd`/bc_out

mkdir -p $BIN

TARGETS="bt cg ep ft is lu mg sp"

#OPT_FLAGS="-unroll-threshold=10 -load path/to/libextension.so"

LFLAGS="-mcmodel=medium -lm"

for t in $TARGETS; do
    $MOPT $OPT_FLAGS $BCS/$t.S.bc -o $BCS/${t}_opt.S.bc -Oz
    $VCLANG $LFLAGS -o $BIN/$t.S.x $BCS/${t}_opt.S.bc
done
