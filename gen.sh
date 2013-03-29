#!/bin/bash

if [ ! $# -eq 1 ]
then
    echo "usage: $0 genome-file"
    exit
fi

./freq.rb $1 >$1-with-frequency

echo ignoring verbose output
grep -v "\*\*" $1-with-frequency >$1-with-frequency-existing

echo sorting
cat $1-with-frequency-existing | sort -k 7 >$1-with-frequency-existing-sorted

echo Done!
