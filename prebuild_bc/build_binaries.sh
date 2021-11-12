#!/bin/bash

VAN=/home/vseeker/workspace/llvm/install/bin
MOD=/media/vseeker/seagate/llvm/auto2tune/instrumented/bin

VCLANG=${VAN}/clang

VOPT=${VAN}/opt
MOPT=${MOD}/opt

BIN=`pwd`/bin
BCS=`pwd`/bc_out

mkdir -p $BIN

TARGETS="bt cg ep ft is lu mg sp"

OPT_FLAGS="-unroll-threshold=10 -load /media/vseeker/seagate/auto2_dist_out/eval_run_0_2021-11-12_12-42-07/worker_output/PATH_WORKER_11/probe_out_1636721425/libextension.so"

LFLAGS="-mcmodel=medium -lm"

for t in $TARGETS; do
    $MOPT $OPT_FLAGS $BCS/$t.S.bc -o $BCS/${t}_opt.S.bc -Oz
    $VCLANG $LFLAGS -o $BIN/$t.S.x $BCS/${t}_opt.S.bc
done
