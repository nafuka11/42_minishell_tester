#!/bin/bash

# ------------------------------------------------------------------------------
# User settings
# ------------------------------------------------------------------------------
readonly MINISHELL_DIR="../minishell"
readonly MINISHELL_EXE="minishell_leaks"
readonly MAKE_TARGET="leaks"
# ------------------------------------------------------------------------------

readonly SCRIPT_FILE="$0"
readonly LOG_FILE_NAME="leaks.log"

source scripts/helper.sh

build_executable () {
	make -C "${MINISHELL_DIR}" "${MAKE_TARGET}"
}

execute_shell () {
	exec_minishell "$1" > ${MINISHELL_STDOUT_FILE} 2> /dev/null
}

assert () {
	if is_ok ; then
		printf "${COLOR_GREEN}"
		print_case "$1" "$2"
		printf " [ok]${COLOR_RESET}\n"
		let result_ok++
	else
		printf "${COLOR_RED}"
		print_case "$1" "$2"
		printf " [ko]${COLOR_RESET}\n"
		cat ${MINISHELL_STDOUT_FILE} | grep bytes
		let result_ko++
	fi
}

is_ok () {
	cat ${MINISHELL_STDOUT_FILE} | grep "0 leaks for 0 total leaked bytes." > /dev/null
	return $?
}

output_log () {
	echo "---------------------------------" >> ${LOG_FILE}
	if is_ok ; then
		echo -n "[OK] " >> ${LOG_FILE}
	else
		echo -n "[KO] " >> ${LOG_FILE}
	fi
	echo $(print_case "$1" "$2") >> ${LOG_FILE}
	echo "---------------------------------" >> ${LOG_FILE}
	cat ${MINISHELL_STDOUT_FILE} | grep bytes >> ${LOG_FILE}
}

main $@
