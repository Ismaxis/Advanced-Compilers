#!/bin/bash

for test in \
    "factorial 120 $(( 1024 * 8 )) 5 factorial" \
    "factorial-in-place 120 $(( 512 * 8 )) 5 factorial-in-place" \
    "fib-tuple 55 $(( 384 * 8 )) 10 fib-tuple" \
    "inc 12 $(( 64 * 8 )) 10 inc" \
    "exp-many-writes 1024 $(( 3072 * 8 )) 10 exp-many-writes"
do
    set -- $test
    name=$1
    expected=$2
    mem=$3
    input=$4
    target=$5
    result=$(bash run.sh -l rust -f "" -m "$mem" -i "$input" -t "$target")
    if [ "$result" -eq "$expected" ]; then
        echo -e "✅ $name: ok"
    else
        echo -e "❌ $name: fail"
    fi
done
