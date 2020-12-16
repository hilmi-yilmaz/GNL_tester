#!/bin/bash

# This is a tester for the get_next_line project in the 42 curriculum. 

# Colors
GREEN="\e[1;32m"
RED="\e[1;31m"
CYAN_B="\e[1;46m"
BLUE_B="\e[1;44m"
RESET="\e[0m"

# Define variables
CC=gcc
C_FLAGS="-Wall -Wextra -Werror -g"
BUFFER_SIZE=1
SRC="src/get_next_line.c src/get_next_line_utils.c"
MAINS=mains/
TEST_FILES="test_files/*"
OUTPUT=output
VALGRIND_FLAGS="--leak-check=full --show-leak-kinds=all --track-origins=yes --verbose"

#Utils functions
clean () 
{
	rm result output
	return
}

check () # this function takes 3 parameters: BUFFER_SIZE step, BUFFER_SIZE end, main source file to test with
{
	for test_file in $TEST_FILES
	do
		test_file_name=$(echo $test_file | cut -d '/' -f 2)
		echo -e "	${CYAN_B}Testing on $test_file_name.${RESET}"
		while [[ "$BUFFER_SIZE" -le "$2" ]]; do

			#Compiling with ASAN
			$CC $C_FLAGS -fsanitize=address -D BUFFER_SIZE=$BUFFER_SIZE ${MAINS}$3 $SRC -o $OUTPUT

			#Redirecting output to result.
			./$OUTPUT $test_file > result

			if [[ "$?" == 1 ]]; then
				echo -e "		${RED}Does not work with basic input. Fix this issue before continuing.${RESET}"
				echo -e "		${RED}Error with $test_file_name and BUFFER_SIZE=$BUFFER_SIZE."
				exit 1
			fi

			#Checking for differences in test_file and result. If the invalid_fd_main.c is tested, the output is compared to an empty file
			if [[ "$3" == "main.c" ]]; then
				echo "diff with $3 and $test_file_name." >> logs/diffs/diff_${test_file_name}
				diff result $test_file >> logs/diffs/diff_${test_file_name}
			elif [[ "$3" == "invalid_fd_main.c" ]]; then
				echo "diff with $3 and $test_file_name." >> logs/diffs/diff_${test_file_name}
				diff result utils/output_invalid_fd >> logs/diffs/diff_${test_file_name}
			fi
		
			if [[ ! $? == 0 ]]; then
				echo -e "		${RED}Does not work with $test_file_name. The output of your program doesn't match the actual result. See logs/diffs/${test_file_name}${RESET}" >&2
			else
				echo -e "		${GREEN}Passed with BUFFER_SIZE=$BUFFER_SIZE.${RESET}"
			fi

			#Check for memory leaks with valgrind
			valgrind $VALGRIND_FLAGS ./$OUTPUT $test_file >> logs/valgrind/"valgrind_${test_file_name}" 2>&1

			#If we have a leak or other memory error
			grep -q "no leaks are possible" logs/valgrind/valgrind_${test_file_name}
			if [[ ! $? == 0 ]]; then
				echo -e "		${RED}You have a leak! Look in logs/valgrind/valgrind_${test_file_name} to find where the leak is.${RESET}" >&2
			fi

			#Change BUFFER_SIZE
			BUFFER_SIZE=$((BUFFER_SIZE + "$1"))
		done
		BUFFER_SIZE=1
	done
	return
}

#Check for existence of source and headerfiles
if [[ ! -f "src/get_next_line.c" || ! -f "src/get_next_line_utils.c" || ! -f "src/get_next_line.h" ]]; then
	echo "Not all submission files are found. Put get_next_line.c, get_next_line_utils.c and get_next_line.h in src/."
	exit 1
fi

#Create the logs directory if it does not exist yet
[[ -d "logs" ]] || mkdir logs

#Create valgrind directory inside logs directory if it does not exist yet. If it exists, clean the valgrind directory.
if [[ ! -d "logs/valgrind" ]]; then
	mkdir logs/valgrind/
else
	rm logs/valgrind/*
fi

#Create diff directory inside logs directory if it does not exist yet. If it exists, clean the diffs directory.
if [[ ! -d "logs/diffs" ]]; then
	mkdir logs/diffs/
else
	rm logs/diffs/*
fi

#Check with regular files
echo -e "${BLUE_B}Test with main.c.${RESET}"
check 2 2 main.c # step, end, main_file
echo -e "\n"

#Check on invalid file descriptor
echo -e "${BLUE_B}Test with invalid_fd_main.c.${RESET}"
check 1 1 invalid_fd_main.c
echo -e "\n"

#Check with stdin
echo -e "${BLUE_B}Test with stdin_main.c.${RESET}"
echo -e "Enter some text, if you are done type CTRL-D."
$CC $C_FLAGS -fsanitize=address -D BUFFER_SIZE=$BUFFER_SIZE ${MAINS}stdin_main.c $SRC -o $OUTPUT
./$OUTPUT

#Cleaning up
clean
