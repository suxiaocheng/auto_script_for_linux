#!/bin/bash

check_exit_code() {
        if [ "$?" -ne "0" ]; then
                echo "[ERR] program exit unnormal $1"
                exit 1
        fi
}

check_err_code() {
	if [ "$1" -ne "0" ]; then
		echo "[ERR] cmd execute fail"
		exit 1
	fi
}

insert_str() {
        # Add execute environment var
        env_status=`cat ${target_dir}${target_file} | grep "${1}"`

        if [ -z "${env_status}" ];then
                echo "[INFO] ${1} is not set, insert it"
                echo "${2}" >> ${target_dir}${target_file}
        fi
}

insert_str_export() {
        # Add execute environment var
        compare_str=${1%=*}
        # echo "compare str is ${compare_str}"
        env_status=`cat ${target_dir}${target_file} | grep "${compare_str}"`

        if [ -z "${env_status}" ];then
                echo "{INFO} ${1} is not set, insert it"
                echo "${2}" >> ${target_dir}${target_file}
        fi
}

# it takes 2 arguments
# returns:
#  0 if v1 (1st argument) and v2 (2nd argument) are the same
#  1 if v1 is less than v2
#  2 if v1 is greater than v2
version_cmp() {
    local V1 V2 VN x
    [[ ! $1 =~ ^[0-9]+(\.[0-9]+)*$ ]] && die "Wrong version format!"
    [[ ! $2 =~ ^[0-9]+(\.[0-9]+)*$ ]] && die "Wrong version format!"

    V1=( $(echo $1 | tr '.' ' ') )
    V2=( $(echo $2 | tr '.' ' ') )
    VN=${#V1[@]}
    [[ $VN -lt ${#V2[@]} ]] && VN=${#V2[@]}

    for ((x = 0; x < $VN; x++)); do
        [[ ${V1[x]} -lt ${V2[x]} ]] && return 1
        [[ ${V1[x]} -gt ${V2[x]} ]] && return 2
    done

    return 0
}

die() {
    [[ -n "$1" ]] && echo -e "\nERROR: $1\n" >&2
    # send die signal to the main process
    [[ $BASHPID -ne $$ ]] && kill -USR2 $$
    # we don't need to call cleanup because it's traped on EXIT
    exit 1
}

stop_service() {
	sudo systemctl stop $1
}

install_and_start_service() {
	if [ -d "/usr/lib/systemd/system/" ]; then
		sudo cp $1 /lib/systemd/system/
	elif [ -d "/etc/systemd/system" ]; then
		sudo cp $1 /etc/systemd/system/
	else
		echo "Install service fail"
		exit 1
	fi
	check_exit_code "copy service[${1}] fail"
	
	sudo systemctl daemon-reload
	sudo systemctl enable $1
	sudo systemctl start $1
	sync
}

rand(){
        min=$1
        max=$(($2-$min+1))
        num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
        echo $(($num%$max+$min))
}
