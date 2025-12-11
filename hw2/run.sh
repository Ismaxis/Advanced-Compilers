#!/bin/bash

set -e

TEST_NAME=factorial
LANG="rust"
BUILD=debug
MAX_ALLOC_SIZE=1024
INPUT=2
FLAGS="-DSTELLA_GC_STATS -DSTELLA_RUNTIME_STATS"
while getopts "t:l:b:m:i:f:" opt; do
    case $opt in
        t)
            TEST_NAME=$OPTARG
            ;;
        l)
            LANG=$OPTARG
            ;;
        b)
            BUILD=$OPTARG
            ;;
        m)
            MAX_ALLOC_SIZE=$OPTARG
            ;;
        i)
            INPUT=$OPTARG
            ;;
        f)
            FLAGS=$OPTARG
            ;;
    esac
done
FULL_LOC=$TEST_NAME

docker run --rm -i fizruk/stella compile < tests/$TEST_NAME.st > $TEST_NAME.c

mkdir -p build
EXECUTABLE=build/$FULL_LOC-$LANG

if [[ $LANG == "C" ]]; then
    gcc -std=c11 $FULL_LOC.c stella/runtime.c stella/gc.c -o $EXECUTABLE
elif [[ $LANG == "rust" ]]; then
    export RUST_BACKTRACE=1 
    if [[ $BUILD == "debug" ]]; then
        docker run --rm -v "$PWD":/volume -w /volume rust cargo build
    else 
        docker run --rm -v "$PWD":/volume -w /volume rust cargo build --$BUILD
    fi
    docker run --rm -v "$PWD":/volume -w /volume gcc:15.2 /bin/bash -c "gcc -std=c11 \
        $FLAGS -DMAX_ALLOC_SIZE=$MAX_ALLOC_SIZE $FULL_LOC.c stella/runtime.c \
        -Ltarget/$BUILD -lstella_gc -o $EXECUTABLE && \
        echo $INPUT | LD_LIBRARY_PATH=./target/$BUILD:\$LD_LIBRARY_PATH ./$EXECUTABLE 2>&1"
fi
