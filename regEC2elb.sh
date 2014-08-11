#!/bin/sh
# Purpose: Add/remove AWS instance from elb load balancer
# Version: 081014
# Author: AlphaMusk.com

# Check to for entry
if [ -z "${1}" ] && [ -z "${2}" ] && [ -z "${3}" ]
then
	echo
	echo "Usage: ${0} [aws region name] [search string for LoadBalancerName]"
	echo
	echo "Example: ${0} us-west-2 myloadbalancer1"
	echo
	exit 100;
fi

if [ "${3}" != 'register' ] && [ "${3}" != 'deregister' ]
then
	echo "Error: Invalid acion to perform on loadbalancer, choose \"register\" or \"deregister\""
	echo 
	exit 100;
fi


# Set vars
REGION="${1}"		# Get the region
LBSEARCH="${2}"		# Search string for lb
ACTION="${3}"		# action to perform, register, deregister

# Check for awscli, install if needed
type -p aws >/dev/null 2>&1
if [ "$(echo $?)" != '0' ]
then
	echo
	echo "Searching for loadbalancer named \"${LBSEARCH}\" in region \"${REGION}\""
	echo
else
	echo "WARNING: awscli is required, but it's not installed."
	echo "Installing awscli"
	sudo apt-get install awscli -y >/dev/null 2>&1
fi




# Set the default region
export AWS_DEFAULT_REGION=${REGION}


# Get the instance-id
INSTANCEID=$(curl --silent http://169.254.169.254/latest/meta-data/instance-id)


# Get instance hostname
LOCALHOSTNAME=$(curl --silent http://169.254.169.254/latest/meta-data/local-hostname)
PUBLICHOSTNAME=$(curl --silent http://169.254.169.254/latest/meta-data/public-hostname)


# Get IP addresses
LOCALIP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLICIP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)


# Find load balance
LBNAME=$(aws elb describe-load-balancers --output text --query 'LoadBalancerDescriptions[*].[LoadBalancerName]' | grep -i ${LBSEARCH})


if [ -z "${LBNAME}" ]
then
	echo "Error: nothing found when searching for loadbalancer ${LBSEARCH}"
	exit 100;
else 
	echo "Found an loadbalancer named \"${LBNAME}\""
fi	

# Results
echo '-------------------------------------------------------------------------'
echo "action = ${ACTION}"
echo "region = ${REGION}"
echo "instance-id = ${INSTANCEID}"
echo "hostname = ${LOCALHOSTNAME}"
echo "local-ipv4 = ${LOCALIP}"
echo "public-hostname = ${PUBLICHOSTNAME}"
echo "public-ipv4 = ${PUBLICIP}"
echo "load-balancer = ${LBNAME}"
echo '-------------------------------------------------------------------------'


# Register action
if [ "${ACTION}" = 'register' ]
then
	echo "Registering \"${INSTANCEID}\" on loadbalancer \"${LBNAME}\""
	CMD="aws elb register-instances-with-load-balancer --load-balancer-name ${LBNAME} --instances ${INSTANCEID}"
	echo "${CMD}"
	${CMD}
	exit 0;
fi

# Deregister action
if [ "${ACTION}" = 'deregister' ]
then
	echo "Deregistering \"${INSTANCEID}\" on loadbalancer \"${LBNAME}\""
	CMD="aws elb deregister-instances-from-load-balancer --load-balancer-name ${LBNAME} --instances ${INSTANCEID}"
	echo "${CMD}"
	${CMD}
	exit 0;
fi




#"Resource":"arn:aws:elasticloadbalancing:region:your-account-id:loadbalancer/your-load-balancer-name"
#"Resource":"arn:aws:elasticloadbalancing:us-west-2:439941837188:loadbalancer/*"


