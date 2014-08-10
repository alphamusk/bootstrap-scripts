#!/bin/bash
# Get lastest git code
# Version: 140621, 140809
# Author: AlphaMusk.com

num='0'
pause='5'
dirpath="${1}"
giturl="${2}"
gitrepo="${3}"
maxrun="${4}"
codepath="${dirpath}/${gitrepo}"

# Check if local dir for repository was specified
if [ "${1}" = '' ]
then
	echo "Error: directory path for code required!"
	echo "${0} [directory path for code] [git repository name]"
	exit;
fi

# Check if git repo was specified
if [ "${2}" = '' ]
then
	echo "Error: git url required!"
	echo "${0} [git url]"
	exit;
fi

# Check if git repo was specified
if [ "${3}" = '' ]
then
	echo "Error: git repository name required!"
	echo "${0} [git repository name]"
	exit;
fi

# Check if a max run count was specified, defaults to 1 run
if [ "${4}" = '' ] || [ "${4}" = 0 ]
then
	echo "Maximum run not specified, running ${0} once"
	maxrun='1'
fi

# Change location to dirpath
cd ${codepath} > /dev/null 2>&1
if [ "$(echo $?)" != '0' ]
then
	echo "Error: git repository not cloned to ${codepath}"
	echo "Run: cd ${dirpath} && git clone ${giturl}/${gitrepo}"
	exit;
fi

# Pull code from specified git repo
while [ "${num}" != "${maxrun}" ]
do
	echo '';
	echo '----------------------------------------------------------------------------------------------';
	echo "Pulling git code from: ${giturl}/${gitrepo}"
	git pull ${giturl}${gitrepo}.git
	echo '----------------------------------------------------------------------------------------------';
	
	# Increment run count
	num=$((${num} + 1))

	# If maxrun is greater than 1
	if [ ${maxrun} != 0 ] && [ ${maxrun} != 1 ] && [ ${maxrun} != ${num} ]
	then
		echo "Run: ${num} of ${maxrun}";
		echo ''
		echo "Sleeping for ${pause} seconds";
		sleep "${pause}";
	else
		# Last run
		echo "Run: ${num} of ${maxrun}";
		echo ''
		exit;
	fi
done