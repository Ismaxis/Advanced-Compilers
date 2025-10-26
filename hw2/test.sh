#!/bin/bash

echo factorial $[ $(bash run.sh -l rust -f "" -m $(( 1024 * 8 )) -i 5 -t factorial) == 120 ]
echo factorial-in-place $[ $(bash run.sh -l rust -f "" -m $(( 512 * 8 )) -i 5 -t factorial-in-place) == 120 ]
echo fib-tuple $[ $(bash run.sh -l rust -f "" -m $(( 384 * 8 )) -i 10 -t fib-tuple) == 55 ]
echo inc $[ $(bash run.sh -l rust -f "" -m $(( 64 * 8 )) -i 10 -t inc) == 12 ]
echo exp-many-writes $[ $(bash run.sh -l rust -f "" -m $(( 3072 * 8 )) -i 10 -t exp-many-writes) == 1024 ]
