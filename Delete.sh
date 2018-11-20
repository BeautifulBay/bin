#!/bin/bash

function rm_product()
{
	for var in `ls -a | grep -v "^\."`
	do
		if [ -L $var ]
		then
			continue
		elif [ -d $var ]
		then
			(cd $var; if [ $? -ne 0 ]; then continue ; fi; rm_product $var)
		fi
	done
	pwd
	cd ../
	rm $1 -r
}

function main()
{
	if [ ! $# -eq 2 ]
	then
		echo "Error: You need a parameter!"
		echo "Usage: $1 Dir/File"
		exit
	fi

	if [ -d $2 ]; then
		cd $2
		rm_product $2
	elif [ -L $2 ]; then
		echo "$2 is a link file"
		echo "Are you sure that you want to delete $2?(Y/n)"
		read input
		if [[ $input == "Y" || $input == "y" ]]; then
			rm $2 -rf
			echo "$2 are deleted!"
		else
			echo "You give up deleting $2!"
		fi
	elif [ -f $2 ]; then
		rm $2 -rf
	else
		echo "Error:Can't delete $2, Please check what it is"
	fi
}

main $0 $@
