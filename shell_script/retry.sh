#!/bin/bash

count=0
if [ $# -gt 0 ]; then
	# echo "[INFO] arg is max than zero"
	if [ -n "$1" ]; then
		while [ true ]; do
			echo "[INFO] Execute command: "$1 " ,times "$count
			${1}
			if [ $? -eq 0 ]; then
				break;
			fi
			count=$((count+1))
			if [ $# -ge 2 ]; then
				if grep '^[[:digit:]]*$' <<< "$2";then
					echo "[INFO] Sleep $2"
					sleep $2
				fi
			fi
		done
	fi
else
	echo "[ERR] arg is null"
fi
