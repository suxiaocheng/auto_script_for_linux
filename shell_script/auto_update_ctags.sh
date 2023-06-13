#!/bin/bash

CSCOPE_SCAN_FILE_LIST=~/.cscope_file.list
CURRENT_DIR=`pwd`
if [ -f ${CSCOPE_SCAN_FILE_LIST} ]; then
	while read line
	do
		echo $line
		if [ -d $line ]; then
			cd $line
			${HOME}/bin/update_ctags.sh
			if [ ! "$?" == "0" ]; then
				echo "Update dir $line error"
			else
				echo $line >> ${CSCOPE_SCAN_FILE_LIST}$$
			fi
		fi
	done < ${CSCOPE_SCAN_FILE_LIST}
fi

cd ${CURRENT_DIR}
rm ${CSCOPE_SCAN_FILE_LIST}

if [ -f ${CSCOPE_SCAN_FILE_LIST}$$ ]; then
	mv ${CSCOPE_SCAN_FILE_LIST}$$ ${CSCOPE_SCAN_FILE_LIST}
fi

