#!/bin/bash

# Function to prompt for user input
function prompt_user() {
    read -p "$1: " val
    echo $val
}

# Check if the docker container exists
if [ $(docker ps -a -f name=azure-openai-proxy | grep -w azure-openai-proxy | wc -l) -eq 1 ]
then
    echo "Removing existing azure-openai-proxy container"
    docker rm -f azure-openai-proxy
fi

# Check if the docker image exists
if [ $(docker images -q ishadows/azure-openai-proxy:latest | wc -l) -eq 1 ]
then
    echo "Removing existing ishadows/azure-openai-proxy image"
    docker rmi ishadows/azure-openai-proxy:latest
fi

# Prompt for user inputs
ENDPOINT=$(prompt_user "Enter AZURE_OPENAI_ENDPOINT")
MAPPER_35=$(prompt_user "Enter MAPPER for gpt-3.5-turbo-0301 (leave empty to skip)")
MAPPER_4=$(prompt_user "Enter MAPPER for gpt-4 (leave empty to skip)")

# Prepare environment variables
ENV_VARS="--env AZURE_OPENAI_ENDPOINT=${ENDPOINT}"
if [ ! -z "$MAPPER_35" ]
then
    ENV_VARS="${ENV_VARS} --env AZURE_OPENAI_MODEL_MAPPER_35=${MAPPER_35}"
fi
if [ ! -z "$MAPPER_4" ]
then
    ENV_VARS="${ENV_VARS} --env AZURE_OPENAI_MODEL_MAPPER_4=${MAPPER_4}"
fi

# Run the Docker container
sudo docker run -d -p 8080:8080 --name=azure-openai-proxy ${ENV_VARS} ishadows/azure-openai-proxy:latest
