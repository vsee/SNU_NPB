#!/bin/bash

source env.config

VCLANG=${VAN}/clang
MCLANG=${MOD}/clang

HOME=../NPB3.3-SER-C

VBIN=`pwd`/vanilla_bins
MBIN=`pwd`/auto2_bins

mkdir -p $VBIN $MBIN

CFLAGS="-Oz -fno-crash-diagnostics"
LFLAGS=""

TARGETS="bt cg ep ft is lu mg sp"
CLASS=S

# configure extension file here for testing
EXTENSION=""

for t in $TARGETS; do
    echo "Building auto2 binaries for $t and class $CLASS"
    ./build.sh $t $CLASS $HOME $MBIN $VCLANG $MCLANG $CFLAGS $LFLAGS $EXTENSION
done

for t in $TARGETS; do
    echo "Building vanilla binaries for $t and class $CLASS"
    ./build.sh $t $CLASS $HOME $VBIN $VCLANG $VCLANG $CFLAGS $LFLAGS ""
done