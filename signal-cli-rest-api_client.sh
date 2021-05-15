#!/bin/sh
# Script: signal-cli-rest-api_client.sh
# Purpose: Send a message over Signal Secure Messenger
# How it works: this script communicates with the signal-cli-rest-api in a Docker container
#	for the docker container see: https://github.com/bbernhard/signal-cli-rest-api
# Author: Florian Hotze


# host of rest api
host="172.0.0.1:8080"

# own phone number of the Signal Client
ownNumber="+4912345678"

declare -A numbers
# contacts' numbers go into this array
numbers=([contact_1]="+4923456789" [contact_2]="+3187654321")

command_not_found() {
	echo "Please provide a command, e.g. send, list_identities, trust_identity"
	exit
}

no_contact_name() {
	echo "Please provide a contact's name"
	exit
}

check_for_contact() {
	if [ -v numbers[$contact] ]
	then
		echo "Contact found."
	else
		echo "Contact not found!"
		exit
	fi
}

send_message() {
	curl 'http://'$host'/v1/send' \
		-X POST \
		-H 'Content-Type: application/json' \
		-d '{"message": "'"$message"'", "number": "'$ownNumber'", "recipients": ["'${numbers[$contact]}'"]}'
}

list_identities() {
	curl 'http://'$host'/v1/identities/'$ownNumber'' \
		-X GET \
		-H "Content-Type: application/json"
}

trust_identity() {
	url='http://'$host'/v1/identities/'$ownNumber'/trust/'${numbers[$contact]}''
	curl "$url" \
		-X PUT \
		-H "Content-Type: application/json" \
		-d '{"verified_safety_number": "{'"$safety_number"'}"}'
}


if [ -z "$1" ];
then
	command_not_found

elif [ $1 = "send" ]
then
	if [ -z "$2" ]
	then
		no_contact_name
	else
		contact=$2
		check_for_contact
		if [ -z "$3" ]
		then
			echo 'Please provide a message. e.g. "message"'
			exit
		else
			message=$3
			send_message
		fi
	fi

elif [ $1 = "list_identities" ]
	then
		list_identities
	
elif [ $1 = "trust_identity" ]
	then
		if [ -z "$2" ]
		then
			no_contact_name
		else
			contact=$2
			check_for_contact
			if [ -z "$3" ]
			then
				echo 'Please provide a safety_number, e.g. "123456 654321 "'
				exit
			else
				safety_number=$3
				trust_identity
			fi
		fi
else
	command_not_found
fi
