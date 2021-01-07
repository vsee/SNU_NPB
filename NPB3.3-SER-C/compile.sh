#!/bin/csh

mkdir -p bin

foreach benchmark ( sp )
    foreach class ( S )
        echo "compiling $benchmark.$class. (SER-C)"
        make $benchmark CLASS=$class
        echo "done.\n"
    end
end
