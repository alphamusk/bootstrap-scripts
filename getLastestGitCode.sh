#!/bin/bash
# Get lastest git code from a git repository based on supplied parameters, made for Ubuntu Linux
# Version: 140621, 140816
# Author: AlphaMusk.com

num='0'
pause='5'
dirpath="${1}"
giturl="${2}/"
gitrepo="${3}"
maxrun="${4}"
codepath="${dirpath}/${gitrepo}"
usage="${0} [local directory path for code] [git url] [git repository] Optional:[max run count]"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

# Check for 3 arguments, one optional
if [ "${#}" -ne '3' ] 
then
	echo ""
	echo "Error: not enough parameters supplied!"
	echo "${usage}"
	echo ""	
	exit 1;
fi


# Check if local dir for repository was specified
if [ -z "${1}" ]
then
	echo ""
	echo "Error: local directory path for code required!"
	echo "${usage}"
	echo ""	
	exit 1;
fi

# Check if git repo was specified
if [ -z "${2}" ]
then
	echo ""
	echo "Error: git url required!"
	echo "${usage}"
	echo ""	
	exit 1;
fi

# Check if git repo was specified
if [ -z "${3}" ]
then
	echo ""
	echo "Error: git repository name required!"
	echo "${usage}"
	echo ""	
	exit 1;
fi

# Check if a max run count was specified, defaults to 1 run
if [ -z "${4}" ]
then
	echo ""
	echo "Warning: Optional maximum run count not specified, running ${0} once."
	echo ""	
	maxrun='1'
fi

if command_exists git
then
	echo "git installed, OK!"
else
	echo "Git is not installed!"
	echo "Installing git"
	apt-get update > /dev/null 2>&1
	apt-get update > /dev/null 2>&1
	apt-get install git -y
fi

# Change location to dirpath
cd "${codepath}" > /dev/null 2>&1
if [ "$(echo $?)" != '0' ]
then
	echo ""
	echo "Warning: git repository not cloned to ${codepath}"
	echo "Running cd ${dirpath} && git clone ${giturl}${gitrepo}"
	cd ${dirpath} && git clone ${giturl}${gitrepo}
	cd ${gitrepo}
	echo ""	
fi

# Pull code from specified git repo
while [ "${num}" != "${maxrun}" ]
do
	echo ""
	echo '----------------------------------------------------------------------------------------------'
	echo "Pulling git code from: ${giturl}${gitrepo}"
	git pull ${giturl}${gitrepo}.git
	echo '----------------------------------------------------------------------------------------------'
	
	# Increment run count
	num=$((${num} + 1))

	# If maxrun is greater than 1
	if [ ${maxrun} != 0 ] && [ ${maxrun} != 1 ] && [ ${maxrun} != ${num} ]
	then
		echo "Run: ${num} of ${maxrun}"
		echo ""
		echo "Sleeping for ${pause} seconds"
		sleep "${pause}"
	else
		# Last run
		echo "Run: ${num} of ${maxrun}"
		echo ""
		exit 0
	fi
done

#EOF