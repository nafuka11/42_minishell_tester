#!/bin/bash

# ------------------------------------------------------------------------------
# Globals:
#   SCRIPT_FILE
#   LOG_FILE_NAME
# ------------------------------------------------------------------------------
cd "$(dirname $0)"

readonly SCRIPT_DIR="$(pwd)"
readonly CASE_DIR="${SCRIPT_DIR}/cases"
readonly OUTPUT_DIR="${SCRIPT_DIR}/outputs"
readonly TEST_DIR="${SCRIPT_DIR}/test"

readonly LOG_FILE="${SCRIPT_DIR}/${LOG_FILE_NAME}"
readonly BASH_STDOUT_FILE="${OUTPUT_DIR}/bash_stdout.txt"
readonly BASH_STDERR_FILE="${OUTPUT_DIR}/bash_stderr.txt"
readonly MINISHELL_STDOUT_FILE="${OUTPUT_DIR}/minishell_stdout.txt"
readonly MINISHELL_STDERR_FILE="${OUTPUT_DIR}/minishell_stderr.txt"

readonly COLOR_RESET="\033[0m"
readonly COLOR_GREEN="\033[32m"
readonly COLOR_RED="\033[31m"

result_all=0
result_ok=0
result_ko=0
cflag=0

run_all_tests () {
	set_minishell_path
	cleanup
	rm -f ${LOG_FILE}
	if [ -n "$1" ]; then
		if [ ! -e "${CASE_DIR}/$1.txt" ]; then
			print_usage
		fi
		build_executable
		run_tests "$1"
	else
		build_executable
		for file in $(ls ${CASE_DIR} | sed 's/\.txt//'); do
			run_tests "${file}"
		done
	fi
}

run_tests () {
	while read -r line; do
		test_cmd=$(echo "$line" | cut -d ',' -f 1)
		setup_cmd=$(echo "$line" | cut -d ',' -f 2- -s)
		execute_shell "$test_cmd" "$setup_cmd"
		assert "$test_cmd" "$setup_cmd"
		output_log "$test_cmd" "$setup_cmd"
	done < "${CASE_DIR}/$1.txt"
	cleanup
}

print_usage () {
	echo "Usage: ${SCRIPT_FILE} [-c] [testcase]"
	echo ""
	echo "Options:"
	echo "  -c    Use -c option to execute shell"
	echo ""
	echo "Testcases:"
	for case in $(ls cases | sed 's/\.txt//' | tr '\n' ' ' | sed 's/ *$//'); do
		echo "  ${case}"
	done
	exit 1
}

cleanup () {
	rm -f ${BASH_STDOUT_FILE} ${BASH_STDERR_FILE} ${MINISHELL_STDOUT_FILE} ${MINISHELL_STDERR_FILE}
	if [ -e "${TEST_DIR}" ]; then
		chmod -R 777 ${TEST_DIR}
		rm -fr ${TEST_DIR}
	fi
}

prepare_test_dir () {
	if [ -e "${TEST_DIR}" ]; then
		chmod -R 777 ${TEST_DIR}
		rm -fr ${TEST_DIR}
	fi
	mkdir -p ${TEST_DIR}
	cd ${TEST_DIR}
	eval "${setup_cmd}"
	cd ${TEST_DIR}
}

set_minishell_path () {
	cd ${SCRIPT_DIR}
	cd ${MINISHELL_DIR}
	MINISHELL_PATH="$(pwd)/${MINISHELL_EXE}"
	cd ${SCRIPT_DIR}
}

print_case () {
	echo  -n "case: $1"
	if [ -n "$2" ]; then
		echo -n " [setup: $(echo $2)]"
	fi
}

show_results () {
	let "result_all = result_ok + result_ko"
	if [ ${result_all} -eq ${result_ok} ]; then
		printf "${COLOR_GREEN}${result_ok}/${result_all}${COLOR_RESET}\n"
		exit 0
	else
		printf "${COLOR_RED}${result_ok}/${result_all}${COLOR_RESET}\n"
		exit 1
	fi
}

exec_bash () {
	prepare_test_dir
	if [ $cflag -ne 0 ]; then
		bash -c "$1"
	else
		echo "$1; exit" | bash
	fi
}

exec_minishell () {
	prepare_test_dir
	if [ $cflag -ne 0 ]; then
		${MINISHELL_PATH} -c "$1"
	else
		echo "$1; exit" | ${MINISHELL_PATH}
	fi
}

main () {
	while getopts ch opt; do
		case "${opt}" in
			c) cflag=1 ;;
			h) print_usage ;;
			*) print_usage ;;
		esac
	done
	shift $(($OPTIND - 1))
	run_all_tests $@
	show_results
}

# ------------------------------------------------------------------------------
# Globals:
#   MINISHELL_DIR
# ------------------------------------------------------------------------------
build_executable () {
	echo "You must implement build_executable ()"
	exit 1
}

# ------------------------------------------------------------------------------
# Arguments:
#   $1: test_cmd
#   $2: setup_cmd
# ------------------------------------------------------------------------------
execute_shell () {
	echo "You must implement execute_shell ()"
	exit 1
}

# ------------------------------------------------------------------------------
# Arguments:
#   $1: test_cmd
#   $2: setup_cmd
# ------------------------------------------------------------------------------
assert () {
	echo "You must implement assert ()"
	exit 1
}

# ------------------------------------------------------------------------------
# Arguments:
#   $1: test_cmd
#   $2: setup_cmd
# ------------------------------------------------------------------------------
output_log () {
	echo "You must implement output_log ()"
	exit 1
}
