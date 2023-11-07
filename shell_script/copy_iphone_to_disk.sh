#!/bin/bash

TARGET_DIR=/run/user/1000/gvfs/gphoto2:host=Apple_Inc._iPhone_00008020001069520C04002E/DCIM
BACKUP_DIR=~/icloud/
FILE_LIST=~/tmp/file_list.$$
LOG_FILE=~/tmp/file_list_copy.log

date >> ${LOG_FILE}

ERR_COUNT=0
CORRECT_COUNT=0
ALREADY_COUNT=0
TOTAL_COUNT=0

if [ ! -d ${TARGET_DIR} ]; then
	echo "[ERR] Target directory is not exist"
fi

find ${TARGET_DIR} -name "*" -type f > ${FILE_LIST}

while read line
do
	TOTAL_COUNT=$(($TOTAL_COUNT+1))
	if [ -f $line ]; then
		FILE_NAME=$(basename $line)
		if [ -f ${BACKUP_DIR}${FILE_NAME} ]; then
			ALREADY_COUNT=$(($ALREADY_COUNT+1))
		else
			cp $line ${BACKUP_DIR}
			if [ "$?" -ne "0" ]; then
				echo "[ERR] copy [$line] fail" | tee -a ${LOG_FILE}

				ERR_COUNT=$(($ERR_COUNT+1))
			else
				echo "[INFO] copy [$line] ok" | tee -a ${LOG_FILE}
				CORRECT_COUNT=$(($CORRECT_COUNT+1))
			fi
		fi
	else
		ERR_COUNT=$(($ERR_COUNT+1))
		
	fi
done < ${FILE_LIST}

rm ${FILE_LIST}

echo "[INFO] =====================================" | tee -a ${LOG_FILE}
echo "[INFO] Total: ${TOTAL_COUNT}" | tee -a ${LOG_FILE}
echo "[INFO] Already copy count: ${ALREADY_COUNT}" | tee -a ${LOG_FILE}
echo "[INFO] Correct copy count: ${CORRECT_COUNT}" | tee -a ${LOG_FILE}
echo "[INFO] Err count: ${ERR_COUNT}" | tee -a ${LOG_FILE}
echo "[INFO] =====================================" | tee -a ${LOG_FILE}
echo "[INFO] Finish copy file" | tee -a ${LOG_FILE}

