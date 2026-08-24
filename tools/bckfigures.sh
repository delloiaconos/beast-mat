#!/bin/bash

srcdir=$1
bckdir=$2
prefix=$3

max=`ls $bckdir/$prefix*.zip | tr -dc '[0-9\n]' | sort -k 1,1n | tail -1`

echo "Max Value Found: $max"

#bckdate=$(date +%Y%m%dT%H%M)

fname=""
printf -v fname "%s%02d" $prefix $((10#$max + 1))
echo "New FileName: $fname"


zip -r "$bckdir/$fname.zip" $srcdir/* 

#mkdir "$bckdir/$fname"
for f in $srcdir/* ; do cp "$f" "$bckdir/"$fname"_"$(basename $f) ; done

echo $iivar
