#!/bin/bash

set -e

TEST_NAME=factorial
FULL_LOC=$TEST_NAME

docker run -i fizruk/stella compile < tests/$TEST_NAME.st > $TEST_NAME.c

LANG="C"
BUILD=debug
while getopts "l:" opt; do
    case $opt in
        l)
            LANG=$OPTARG
            ;;
        b)
            BUILD=$OPTARG
            ;;
    esac
done

echo "[$BUILD]" $LANG 

EXECUTABLE=build/$FULL_LOC-$LANG

if [[ $LANG == "C" ]]; then
    gcc -std=c11 $FULL_LOC.c stella/runtime.c stella/gc.c -o $EXECUTABLE
elif [[ $LANG == "rust" ]]; then
    if [[ $BUILD == "debug" ]]; then
        cargo build 2> build/cargo.log 1> build/cargo.log
    else 
        cargo build --$BUILD 2> build/cargo.log 1> build/cargo.log
    fi
    gcc -std=c11 $FULL_LOC.c stella/runtime.c -Ltarget/$BUILD -lstella_gc -o $EXECUTABLE

    export LD_LIBRARY_PATH=target/$BUILD:$LD_LIBRARY_PATH
    export RUST_LOG=debug
fi

rm $FULL_LOC.c

echo 4 | ./$EXECUTABLE 2>&1

rm $EXECUTABLE
