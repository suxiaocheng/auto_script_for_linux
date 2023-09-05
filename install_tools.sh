#!/bin/bash

source helper.sh

PROGRAM_LIST="git guake tmux make cmake tree cscope curl samba"
ERROR_INSTALL_LIST=""

check_for_binary() {
	if [ -z $1 ]; then
		echo "[INFO] no argument for check_for_binary()"
		return 2
	fi
	binary_exist=`which $1`
	if [ $? -eq 1 ]; then
		echo "[INFO] $1 is not exist"
		return 1
	else
		return 0
	fi
}

try_apt_install_package() {
	count=0
	if [ -z $2 ]; then
		retry=3
	else
		retry=$2
	fi
	package=$1
	while [ ${count} -lt ${retry} ]; do
		sudo apt install -y ${package}
		if [ $? -eq 0 ]; then
			return 0
		fi
		count=$((count+1))
	done
	return 1
}

check_and_install_binary() {
	if [ -z $2 ]; then
		package=$1
	else
		package=$2
	fi
	echo "[INFO] check $1 status"
	check_for_binary $1
	if [ $? -eq 1 ]; then
		try_apt_install_package "${package}" 3
		if [ $? -eq 0 ]; then
			echo "[INFO] ${package} is install ok"
		else
			echo "[ERR] ${package} is install fail"
			return 1
		fi
	elif [ $? -eq 2 ]; then
		echo "[ERR] argument error"
		exit 1
	else
		echo "[INFO] $1 is already install"
	fi
	return 0
}

install_tmux_config(){
	TMUX_PROGRAM=`which tmux`
	CONFIG_FILE=".tmux.conf"
	# install plugin
	if [ ! -d ~/.tmux/plugins/tpm ] ; then
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	fi
	if [ ! -z ${TMUX_PROGRAM} ]; then
		tmux_version=`tmux -V|tmux -V|awk '{print $2}'|tr -d 'a-z'`
		version_cmp $tmux_version 2.3
		if [[ ! "$?" -eq 2 ]]; then
		        CONFIG_FILE=${CONFIG_FILE}"_2.6"
		fi
		if [ -f "config/${CONFIG_FILE}" ]; then
			cp config/${CONFIG_FILE} ${HOME}
			chmod 0777 ${HOME}/${CONFIG_FILE}
		fi
	fi
}

install_vim_plugin_taglist(){
	VIM_PROGRAM=`which vim`

	if [ ! -z ${VIM_PROGRAM} ]; then
		if [ ! -d ~/.vim ]; then
			mkdir ~/.vim
		fi
		rm -rf ~/.vim/doc ~/.vim/plugin
		cp -r taglist/* ~/.vim/
	fi
}

install_shell_script_cmd(){
	BINARY_DIR="$HOME""/bin"
	if [ ! -d ${BINARY_DIR} ]; then
		mkdir ${BINARY_DIR}
	fi
	cp shell_script/* ${BINARY_DIR}
}

install_tool_config(){
	# $1: path, $2: file
	if [ ! -d $1 ]; then
		echo [ERR] install config file [$1] to non-exist path [$1]
		return 1
	fi
	if [ ! -f $2 ]; then
		echo [ERR] config file [$2] is missing
		return 2
	fi
	cp $2 $1
	if [ $? -ne 0 ]; then
		echo [ERR] install config file [$1] to path [$1] fail
		return 3
	fi
	echo [INFO] install config file [$1] to path [$1] ok
	return 0
}

install_vim_plugin(){
	# if [ ! -d ~/.vim/autoload ]; then
	# 	echo "[INFO] autoload not exist, create it"
	# 	mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	# 		curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	# 	err=$?
	# 	if [ "$err" -ne "0" ]; then
	# 		rm -rf ~/.vim/autoload ~/.vim/bundle
	# 	fi
	# 	check_err_code $err
	# fi
	echo "[INFO] Install vim plugin"
}

add_bashrc_execute_enviroement(){
	# Add execute environment var
	env_status=`cat ~/.bashrc | grep "ORIG_PATH"`
	
	if [ -z "${env_status}" ];then
	        echo "env is not set, create it"
	        echo "if [ -z \${ORIG_PATH} ]; then" >> ~/.bashrc
	        echo "        #echo \"ORIG_PATH is not define, redfine it.\"" >> ~/.bashrc
	        echo "        export ORIG_PATH=\${PATH}" >> ~/.bashrc
	        echo "fi" >> ~/.bashrc
	        echo "export PATH=~/bin:\${ORIG_PATH}" >> ~/.bashrc
	fi
}

add_bashrc_alias(){
	check_str_list[0]="c='clear'"
	check_str_list[1]="g='git log --oneline --graph --decorate'"
	check_str_list[2]="i='indent -npro -kr -i8 -ts8 -sob -l80 -ss -ncs'"
	check_str_list[3]="s='source ~/.bashrc'"
	check_str_list[4]="t='tmux attach || tmux'"
	check_str_list[5]="u='update_ctags.sh'"
	check_str_list[6]="p='pwd'"
	check_str_list[7]="z='top -d 1'"
	check_str_list[8]="cp='rsync -av --info=progress2'"

	target_dir="${HOME}/"
	target_file=".bashrc"

	echo "[INFO] ${#check_str_list[*]} command will be check"

	for ((i=0; i< ${#check_str_list[*]}; i++)); do
	        echo ${check_str_list[i]}
	        insert_str "${check_str_list[i]}" "alias ${check_str_list[i]}"
	done
}

add_bashrc_export(){
	check_export_enhanced_list[0]="HISTTIMEFORMAT=\"[%Y-%m-%d %H:%M:%S] \""
	check_export_enhanced_list[1]="INDENTFORMAT=\" -npro -kr -i8 -ts8 -sob -l80 -ss -ncs \""

	target_dir="${HOME}/"
	target_file=".bashrc"

	for ((i=0; i< ${#check_export_enhanced_list[*]}; i++)); do
	        echo ${check_export_enhanced_list[i]}
	        insert_str_export "${check_export_enhanced_list[i]}" "export ${check_export_enhanced_list[i]}"
	done
}

for program in ${PROGRAM_LIST}; do
	check_and_install_binary $program
	if [ $? -eq 1 ]; then
		ERROR_INSTALL_LIST=${ERROR_INSTALL_LIST}" ${program}"
	fi
done

# Install config file
install_tmux_config
install_vim_plugin_taglist
install_vim_plugin

# vimrc update
install_tool_config "${HOME}" "config/.vimrc"
if [ -f ~/bin/ctags ]; then
        sed -e 's/CSCOPE_PROGRAM_WHICH/~\/bin\/cscope/g' \
                -e 's/CTAGS_PROGRAM_WHICH/~\/bin\/ctags/g' config/.vimrc > ~/.vimrc
else
        sed -e 's/CSCOPE_PROGRAM_WHICH/\/usr\/bin\/cscope/g' \
                -e 's/CTAGS_PROGRAM_WHICH/\/usr\/local\/bin\/ctags/g' config/.vimrc > ~/.vimrc
fi

add_bashrc_execute_enviroement
install_shell_script_cmd
add_bashrc_alias
add_bashrc_export


if [ "${ERROR_INSTALL_LIST}" != "" ]; then
	echo "[ERR] these package [${ERROR_INSTALL_LIST} ] is install fail"
	exit 1
fi

exit 0
