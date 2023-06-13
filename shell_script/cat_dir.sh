#!/bin/bash

if [ -n $1 ]; then
	dir=$1
else
	dir=`pwd`
fi

for f in `ls $dir`; do if [ -f $f  ]; then if [ -r $f ]; then  echo $f":"; cat $f; fi; fi;  done
