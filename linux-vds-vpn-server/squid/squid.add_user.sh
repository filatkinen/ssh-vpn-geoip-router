#!/bin/bash
 


DIR_PATH=$(dirname "$(realpath "$0")")
source "$DIR_PATH/variables.sh"

# Check the number of parameters
if [ "$#" -ne 1 ]; then
    echo "Error: exactly 1 parameter is required."
    exit 1
fi


htdigest -c /etc/squid/passwd_digest $REALM  $1