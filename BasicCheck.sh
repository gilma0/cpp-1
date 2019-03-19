#!/bin/bash

path=$1
program=$2
input=$3

compilation=1
memleak=1
threadrace=1

cd $path

if [ -f Makefile ] || [ -f makefile ]; then
	make
	if [ $? -gt 0 ] || [ $? -lt 0 ]; then
	echo "Compilation      Memory leaks    Thread race"
	echo "    FAIL             FAIL            FAIL"
	else
		compilation=0
		compile="PASS"
		valgrind --leak-check=full --error-exitcode=1 ./$program
		if [ $? -gt 0 ] || [ $? -lt 0 ]; then
			mem="FAIL"
			valgrind --tool=helgrind --error-exitcode=1 ./$program
			if [ $? -gt 0 ] || [ $? -lt 0 ]; then
			thread="FAIL"
			else
			thread="PASS"
			threadrace=0
			fi
		else
			memleak=0
			mem="PASS"
			valgrind --tool=helgrind --error-exitcode=1 ./$program
			if [ $? -gt 0 ] || [ $? -lt 0 ]; then
			thread="FAIL"
			else
			thread="PASS"
			threadrace=0
			fi
		fi
	echo "Compilation      Memory leaks    Thread race"
	echo "   "$compile"             "$mem"           " $thread
	fi
	echo

else
	echo "Makefile not found"
fi
echo $((2#$compilation$memleak$threadrace))
exit $((2#$compilation$memleak$threadrace))
