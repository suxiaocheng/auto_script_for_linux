#!/bin/bash

CSCOPE_FILES=cscope.files
CSCOPE_WITH_IGNORE_FILES=cscope_with_ignore.files
CSCOPE_SCAN_FILE_LIST=~/.cscope_file.list
CSCOPE_SCAN_FILE_FOUND=0

if [ ! -f ${CSCOPE_FILES} ]; then
	echo "Not a valid cscope file dir"
	exit 0
fi

rm -rf ${CSCOPE_FILES} ${CSCOPE_WITH_IGNORE_FILES}

rm -rf cscope.out cscope.in.out cscope.po.out

rm -rf tags

CURRENT_DIR=$(pwd)
echo "current dir is: ${CURRENT_DIR}"

egrep "^${CURRENT_DIR}$" ${CSCOPE_SCAN_FILE_LIST}

if [ $? == 0 ]; then
	egrep -v "^${CURRENT_DIR}$" ${CSCOPE_SCAN_FILE_LIST} > ${CSCOPE_SCAN_FILE_LIST}$$
	mv ${CSCOPE_SCAN_FILE_LIST}$$ ${CSCOPE_SCAN_FILE_LIST}
fi

echo "Sucessfully"
