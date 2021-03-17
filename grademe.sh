#!/bin/bash

# ------------------------------------------------------------------------------
# User settings
# ------------------------------------------------------------------------------
readonly MINISHELL_DIR="../"
readonly MINISHELL_EXE="minishell"
# If you launch this script with -c option, MINISHELL_PROMPT is ignored
readonly MINISHELL_PROMPT="minishell $ "
# ------------------------------------------------------------------------------

readonly SCRIPT_FILE="$0"
readonly LOG_FILE_NAME="result.log"

source scripts/helper.sh

build_executable () {
	make -C "${MINISHELL_DIR}"
}

execute_shell () {
	exec_bash "$test_cmd" > ${BASH_STDOUT_FILE} 2> ${BASH_STDERR_FILE}
	bash_status=$?
	exec_minishell "$test_cmd" > ${MINISHELL_STDOUT_FILE} 2> ${MINISHELL_STDERR_FILE}
	minishell_status=$?
	replace_bash_error
}

replace_bash_error () {
	grep "bash: -c" ${BASH_STDERR_FILE} > /dev/null
	if [ $? -eq 0 ]; then
		sed -i "" -e 's/bash: -c: line [0-9]*:/minishell:/g' -e '2d' ${BASH_STDERR_FILE}
	else
		sed -i "" -e 's/bash: line [0-9]*:/bash:/g' ${BASH_STDERR_FILE}
		sed -i "" -e 's/bash:/minishell:/g' ${BASH_STDERR_FILE}
	fi
	if [ $cflag -eq 0 ]; then
		sed -i "" -e "s/${MINISHELL_PROMPT}//g" -e "/^exit$/d" ${MINISHELL_STDERR_FILE}
		sed -i "" -e '/minishell: `.*exit/d' -e '/minishell: syntax error: unexpected end of file/d' ${BASH_STDERR_FILE}
	fi
}

assert () {
	diff_stdout=$(diff ${MINISHELL_STDOUT_FILE} ${BASH_STDOUT_FILE})
	diff_stderr=$(diff ${MINISHELL_STDERR_FILE} ${BASH_STDERR_FILE})
	if is_ok ; then
		printf "${COLOR_GREEN}"
		print_case "$1" "$2"
		printf " [ok]${COLOR_RESET}\n"
		let result_ok++
	else
		printf "${COLOR_RED}"
		print_case "$1" "$2"
		printf " [ko]${COLOR_RESET}\n"
		if [ ${minishell_status} -ne ${bash_status} ]; then
			printf "exit status: minishell=${minishell_status} bash=${bash_status}\n"
		fi
		if [ -n "${diff_stdout}" ]; then
			printf "${diff_stdout}\n"
		fi
		if [ -n "${diff_stderr}" ]; then
			printf "${diff_stderr}\n"
		fi
		let result_ko++
	fi
}

is_ok () {
	if [ -z "${diff_stdout}" ] && [ -z "${diff_stderr}" ] && [ ${minishell_status} -eq ${bash_status} ]; then
		return 0
	fi
	return 1
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
	echo "# minishell: stdout" >> ${LOG_FILE}
	cat "${MINISHELL_STDOUT_FILE}" >> ${LOG_FILE}
	echo "# bash     : stdout" >> ${LOG_FILE}
	cat "${BASH_STDOUT_FILE}" >> ${LOG_FILE}
	echo "# minishell: stderr" >> ${LOG_FILE}
	cat "${MINISHELL_STDERR_FILE}" >> ${LOG_FILE}
	echo "# bash     : stderr" >> ${LOG_FILE}
	cat "${BASH_STDERR_FILE}" >> ${LOG_FILE}
	echo "# minishell: exit status = ${minishell_status}" >> ${LOG_FILE}
	echo "# bash     : exit status = ${bash_status}" >> ${LOG_FILE}
}

main $@
