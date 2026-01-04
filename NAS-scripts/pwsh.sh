#!/bin/bash
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run with sudo."
   exit 1
fi

CONTAINER_NAME="pwsh"
IMAGE_NAME="mcr.microsoft.com/powershell:latest"

docker_run() {
    docker run -it --name $CONTAINER_NAME \
        --mount type=bind,source=/mnt,target=/mnt \
        -v pwsh_history:/root/.local/share/powershell/ \
        --workdir /mnt \
        $IMAGE_NAME \
        pwsh
}

# 1. Check if the container exists and get its status
STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "No container named '$CONTAINER_NAME' found. Starting fresh..."
    docker_run

    echo "Use [Ctrl + P + Q] to detach from the container without stopping it."

    exit 0
fi

echo "Container $CONTAINER_NAME currently exists (Status: $STATUS)."
echo "What would you like to do?"
echo "1) Resume existing session"
echo "2) Delete and start fresh"
read -p "Select an option [1-2]: " choice

case $choice in
    1)
        if [ "$STATUS" == "paused" ]; then
            echo "Unpausing container ..."
            docker unpause $CONTAINER_NAME
            docker attach $CONTAINER_NAME
        elif [ "$STATUS" == "running" ]; then
            echo "Attaching to running container ..."
            docker attach $CONTAINER_NAME
        else
            echo "Starting stopped container..."
            docker start -ai $CONTAINER_NAME
        fi
        ;;
    2)
        echo "Removing $CONTAINER_NAME ..."
        docker rm -f $CONTAINER_NAME

        echo "Starting fresh session ..."
        docker_run
        
        echo "Use [Ctrl + P + Q] to detach from the container without stopping it."
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac