#!/bin/bash

rm -rf bc_out build auto2_bins vanilla_bins
rm -rf ../NPB3.3-SER-C/sys/setparams

for i in `find ../NPB3.3-SER-C -name "npbparams.h"`; do 
    rm $i
done
