#!/bin/bash

source env.config

VCLANG=${VAN}/clang
VLINK=${VAN}/llvm-link
VOPT=${VAN}/opt
VSIZE=${VAN}/llvm-size

WD=`pwd`
HOME=`pwd`/../NPB3.3-SER-C
SYS=$HOME/sys
COMMON=$HOME/common

BENCH_CFLAGS="-fno-crash-diagnostics -Wall -mcmodel=medium"
BENCH_LFLAGS="-mcmodel=medium -lm"

CFLAGS_BC="-Oz -Xclang -disable-llvm-passes -Xclang -disable-llvm-optzns ${BENCH_CFLAGS}"
CFLAGS_O="-Oz ${BENCH_CFLAGS}"
OPT_FLAGS="-Oz"
LFLAGS="-Oz ${BENCH_LFLAGS}"


BLD=`pwd`/build

DBIN="direct_bins"
OBIN="opt_bins"

function execute {
    CMD=$1
    echo $CMD
    $CMD
}

mkdir -p $BLD $DBIN $OBIN

# build param tool
# generate header parameters from make config
# make config is otherwise irrelevant for our purposes though
execute "gcc -o $SYS/setparams $SYS/setparams.c"


function build_benchmark {
    NAME=$1
    DIR=$2
    SRC=$3
    CMN=$4
    VFY=$5

    printf "\n\n=========================================\nBuilding $NAME\n====================================\n"

    cd $DIR
    $SYS/setparams $NAME S
    cd $BLD
    mkdir -p $NAME
    cd $NAME
    
    echo "Building object files directly ..."
    for file in $CMN; do
        execute "$VCLANG $CFLAGS_O -c -I$COMMON $COMMON/$file"
    done
    for file in $SRC; do
        execute "$VCLANG $CFLAGS_O -c -I$COMMON -I$DIR $DIR/$file"
    done
    execute "$VCLANG $CFLAGS_O -c $DIR/$VFY"

    echo "Linking object to binary ..."
    CMN_O=${CMN//\.c/\.o}
    SRC_O=${SRC//\.c/\.o}
    VFY_O=${VFY//\.c/\.o}

    execute "$VCLANG $LFLAGS $CMN_O $SRC_O $VFY_O -o ../../$DBIN/${NAME}.x"


    echo "\nBuilding bitcode and optimizing separately ..."
    # # step 1: make sure the right function attributes get set:
    # clang in.c -o in.bc -Oz -emit-llvm -c -Xclang -disable-llvm-passes -Xclang -disable-llvm-optzns
    # # step 2: run your opt magic here:
    # opt -Oz in.bc -o out.bc
    # # step 3: need -Oz to enable lowering optzns:
    # clang out.bc -o a.out -Oz

    for file in $CMN; do
        execute "$VCLANG $CFLAGS_BC -emit-llvm -c -I$COMMON $COMMON/$file"
    done
    for file in $SRC; do
        execute "$VCLANG $CFLAGS_BC -emit-llvm -c -I$COMMON -I$DIR $DIR/$file"
    done
    # external verification is linked in from previously built object file

    echo "Linking to large bitcode file."
    CMN_BC=${CMN//\.c/\.bc}
    SRC_BC=${SRC//\.c/\.bc}
    OUT_BC="${NAME}.large.bc"
    OUT_BC_OPT="${NAME}_opt.large.bc"
    execute "$VLINK $CMN_BC $SRC_BC -o ${OUT_BC}"

    echo "Optimising large bitcode file."
    execute "$VOPT $OPT_FLAGS ${OUT_BC} -o ${OUT_BC_OPT}"

    echo "Linking optimized bitcode to binary ..."
    execute "$VCLANG $LFLAGS ${OUT_BC_OPT} $VFY_O -o ../../$OBIN/${NAME}.x"
}

build_benchmark mg \
    $HOME/MG \
    "mg.c" \
    "print_results.c randdp.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark cg \
    $HOME/CG \
    "cg.c" \
    "print_results.c randdp.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark bt \
    $HOME/BT \
    "bt.c initialize.c exact_solution.c exact_rhs.c
     set_constants.c adi.c  rhs.c
     x_solve.c y_solve.c solve_subs.c
     z_solve.c add.c error.c verify.c" \
    "c_timers.c wtime.c print_results.c" \
    "auto2_verify.c"

build_benchmark ep \
    $HOME/EP \
    "ep.c" \
    "print_results.c randdp.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark ft \
    $HOME/FT \
    "appft.c auxfnct.c fft3d.c mainft.c verify.c" \
    "print_results.c randdp.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark is \
    $HOME/IS \
    "is.c" \
    "c_print_results.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark lu \
    $HOME/LU \
    "lu.c read_input.c \
    domain.c setcoeff.c setbv.c exact.c setiv.c
    erhs.c ssor.c rhs.c l2norm.c
    jacld.c blts.c jacu.c buts.c error.c
    pintgr.c verify.c" \
    "print_results.c c_timers.c wtime.c" \
    "auto2_verify.c"

build_benchmark sp \
    $HOME/SP \
    "sp.c initialize.c exact_solution.c exact_rhs.c
     set_constants.c adi.c rhs.c
     x_solve.c ninvr.c y_solve.c pinvr.c
     z_solve.c tzetar.c add.c txinvr.c error.c verify.c" \
    "print_results.c c_timers.c wtime.c" \
    "auto2_verify.c"


printf "\n==================================\nResults\n==================================\n"
cd $WD
echo "Direct Build"
ls $DBIN/*.x -l

echo "Opt Build"
ls $OBIN/*.x -l

printf "\nLLVM-SIZE\n"
echo "Direct Build"
$VSIZE $DBIN/*.x

echo "Opt Build"
$VSIZE $OBIN/*.x