#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo."
   exit 1
fi

CONTAINER_NAME="pwsh"

docker rm -f $CONTAINER_NAME