#!/bin/bash

source env.config

VCLANG=${VAN}/clang
VOPT=${VAN}/opt
VDISS=${VAN}/llvm-dis
MOPT=${MOD}/opt

BCS=`pwd`/bc_out

TARGETS="bt cg ep ft is lu mg sp"

LFLAGS="-mcmodel=medium -lm"

# build binary versions using modified optimiser and extension
BIN=`pwd`/auto2_bins
mkdir -p $BIN
OPT_FLAGS="-unroll-threshold=10 -load /media/vseeker/seagate/auto2_dist_out/eval_run_0_2021-11-17_11-04-48/worker_output/PATH_WORKER_1/probe_out_1637147724/libextension.so"

for t in $TARGETS; do
    $MOPT $OPT_FLAGS $BCS/$t.S.bc -o $BCS/${t}_opt.S.bc -Oz
    $VCLANG $LFLAGS -o $BIN/$t.S.x $BCS/${t}_opt.S.bc
    $VDISS $BCS/$t.S.bc -o $BIN/$t.S.ll
    $VDISS $BCS/${t}_opt.S.bc -o $BIN/${t}_opt.S.ll
done

# build binary versions using vanilla optimiser
BIN=`pwd`/vanilla_bins
mkdir -p $BIN
OPT_FLAGS="-unroll-threshold=10"

for t in $TARGETS; do
    $VOPT $OPT_FLAGS $BCS/$t.S.bc -o $BCS/${t}_opt.S.bc -Oz
    $VCLANG $LFLAGS -o $BIN/$t.S.x $BCS/${t}_opt.S.bc
    $VDISS $BCS/$t.S.bc -o $BIN/$t.S.ll
    $VDISS $BCS/${t}_opt.S.bc -o $BIN/${t}_opt.S.ll
done

