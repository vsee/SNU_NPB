#!/bin/bash

rm -rf bc_out build bin
rm -rf ../NPB3.3-SER-C/sys/setparams

for i in `find ../NPB3.3-SER-C -name "npbparams.h"`; do 
    rm $i
done
