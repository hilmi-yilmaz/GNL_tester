#!/bin/bash

#This is a tester for the get_next_line project in the 42 curriculum.

#These parameters can be changed by the user of this tester
VALGRIND="0"    #To check with Valgrind, change to "1".

#Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN_B="\033[1;46m"
BLUE_B="\033[1;44m"
RESET="\033[0m"

#Define variables
CC=clang
C_FLAGS="-Wall -Wextra -Werror -g"
SRC="src/get_next_line.c src/get_next_line_utils.c"
MAINS_PATH=mains/
TEST_FILES="test_files/*"
OUTPUT=output
VALGRIND_FLAGS="--leak-check=full --show-leak-kinds=all --track-origins=yes --verbose"

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
	rm -rdf logs/valgrind/ && mkdir logs/valgrind
fi

#Create diff directory inside logs directory if it does not exist yet. If it exists, clean the diffs directory.
if [[ ! -d "logs/diffs" ]]; then
	mkdir logs/diffs/
else
	rm -rdf logs/diffs/ && mkdir logs/diffs
fi

#Create your_results directory inside logs directory if it does not exist yet. If it exists, clean the diffs directory.
if [[ ! -d "logs/your_results" ]]; then
	mkdir logs/your_results/
else
	rm -rdf logs/your_results/ && mkdir logs/your_results
fi

#Create real_results directory inside logs directory if it does not exist yet. If it exists, clean the diffs directory.
#if [[ ! -d "logs/real_results" ]]; then
#	mkdir logs/real_results/
#else
#	rm -rdf logs/real_results/ && mkdir logs/real_results
#fi

#This is the testing function. It takes as inputs:
#   - $1 = main file
#   - $2 = test_file
#   - $3 = BUFFER_SIZE
#
#It compiles the program, executes it and redirects the output to a file.
#Then with the 'diff' command the real_results are compared to your_results.
#Also valgrind and ASAN are used to check for memory errors.

test ()
{
    #Parse the test file name (e.g tests/simple1 --> simple1)
    test_name=$(echo "$2" | cut -d '/' -f 2)

    #Compiling with ASAN
	$CC $C_FLAGS -fsanitize=address -D BUFFER_SIZE=$3 $1 $SRC -o $OUTPUT

    #Redirect output to result
    ./$OUTPUT $2 > logs/your_results/${test_name}_with_buffer_size_$3

    #Checking for differences in real_results and your_results.
    diff logs/your_results/${test_name}_with_buffer_size_$3 real_results/${test_name}_with_buffer_size_$3 >> logs/diffs/${test_name}_with_buffer_size_$3
    if [[ ! $? == 0 ]]; then
		echo -e "	${RED}Does not work with ${test_name}_with_buffer_size_$3. The output of your program doesn't match the actual result." >&2
	else
		echo -e "	${GREEN}Passed with BUFFER_SIZE=$3.${RESET}"
        rm -f logs/diffs/${test_name}_with_buffer_size_$3
    fi

    #Check for memory leaks with valgrind if enabled
    if [[ "$VALGRIND" == "1" ]]; then

        valgrind $VALGRIND_FLAGS ./$OUTPUT $2 >> logs/valgrind/$test_name 2>&1
        #If we have a leak or other memory error
        grep -q "no leaks are possible" logs/valgrind/$test_name
        if [[ ! $? == 0 ]]; then
            echo -e "	${RED}You have a leak! Look in logs/valgrind/$test_name to find where the leak is.${RESET}" >&2
        else
            rm -rf logs/valgrind/$test_name
        fi
    fi

    return
}

# Call the test function on different test files

# ---------------- simple1 ----------------
echo -e "${CYAN_B}Testing on simple1${RESET}"
BUFFER_SIZE=(0 1 2 3 10 11 12 13 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/simple1 $buffer
done

# ---------------- simple2 ----------------
echo -e "${CYAN_B}Testing on simple2${RESET}"
BUFFER_SIZE=(0 1 2 3 10 11 12 13 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/simple2 $buffer
done

# ---------------- simple3 ----------------
echo -e "${CYAN_B}Testing on simple3${RESET}"
BUFFER_SIZE=(0 1 2 3 10 50 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/simple3 $buffer
done

# ---------------- medium1 ----------------
echo -e "${CYAN_B}Testing on medium1${RESET}"
BUFFER_SIZE=(0 1 2 3 10 11 12 13 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/medium1 $buffer
done

# ---------------- medium2 ----------------
echo -e "${CYAN_B}Testing on medium2${RESET}"
BUFFER_SIZE=(0 1 2 3 10 50 100 500)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/medium2 $buffer
done

# ---------------- hard1 ----------------
echo -e "${CYAN_B}Testing on hard1${RESET}"
BUFFER_SIZE=(0 1 2 3 10 50 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/hard1 $buffer
done

# ---------------- hard2 ----------------
echo -e "${CYAN_B}Testing on hard2${RESET}"
BUFFER_SIZE=(0 1 2 3 10 50 100)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/hard2 $buffer
done

# ---------------- hard3 ----------------
echo -e "${CYAN_B}Testing on hard3${RESET}"
BUFFER_SIZE=(0 1 2 3 10 50 100 4000 10000)
for buffer in ${BUFFER_SIZE[@]};
do
    test mains/main.c tests/hard3 $buffer
done

# ---------------- Invalid fd ----------------
echo -e "${CYAN_B}Testing with invalid fd${RESET}"
BUFFER_SIZE=(0 1 2 3 10)
for buffer in ${BUFFER_SIZE[@]};
do
    #Compiling with ASAN
	$CC $C_FLAGS -fsanitize=address -D BUFFER_SIZE=$buffer mains/invalid_fd_main.c $SRC -o $OUTPUT

    #Redirect output to result
    ./$OUTPUT > logs/your_results/invalid_fd_with_buffer_size_$buffer

    #Check for differences
    diff logs/your_results/invalid_fd_with_buffer_size_$buffer real_results/invalid_fd_with_buffer_size_$buffer >> logs/diffs/invalid_fd__with_buffer_size_$buffer
    if [[ ! $? == 0 ]]; then
		echo -e "	${RED}Does not work with invalid_fd_with_buffer_size_$buffer. The output of your program doesn't match the actual result." >&2
	else
		echo -e "	${GREEN}Passed with BUFFER_SIZE=$buffer.${RESET}"
        rm -f logs/diffs/invalid_fd_with_buffer_size_$buffer
    fi

done

# ---------------- stdin ----------------
echo -e "${CYAN_B}Testing on stdin${RESET}"
BUFFER_SIZE=(1 10)
for buffer in ${BUFFER_SIZE[@]};
do
    #Compiling with ASAN
	$CC $C_FLAGS -fsanitize=address -D BUFFER_SIZE=$buffer mains/stdin_main.c $SRC -o $OUTPUT

    #Run executable
    echo -e "${BLUE}Type ctrl-D when you are done.${RESET}"
    echo -e "${GREEN}BUFFER_SIZE=$buffer${RESET}"
    echo ""
    ./$OUTPUT

done

#Clean
rm $OUTPUT