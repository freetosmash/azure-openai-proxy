#!/bin/bash

# Set docker container and image names
CONTAINER_NAME="azure-openai-proxy"
IMAGE_NAME="ishadows/azure-openai-proxy:latest"

# Check if container exists
if [ $(docker ps -a -f name=$CONTAINER_NAME | grep -w $CONTAINER_NAME | wc -l) -eq 1 ]; then
  echo "Removing existing $CONTAINER_NAME container"
  docker rm -f $CONTAINER_NAME
fi

# Check if image exists
if [ $(docker images -f reference=$IMAGE_NAME | grep -w $IMAGE_NAME | wc -l) -eq 1 ]; then
  echo "Removing existing $IMAGE_NAME image"
  docker rmi $IMAGE_NAME
fi

# Enter the Azure OpenAI endpoint
read -p "Enter Azure OpenAI resource name: " resource_name
AZURE_OPENAI_ENDPOINT="https://$resource_name.openai.azure.com/"

# Enter the model mapper values
read -p "Enter MAPPER for gpt-3.5-turbo-0301 (leave empty to skip): " mapper_gpt35
read -p "Enter MAPPER for gpt-4 (leave empty to skip): " mapper_gpt4

# Create the model mapper string
MODEL_MAPPER=""
if [ ! -z "$mapper_gpt35" ]; then
  MODEL_MAPPER="gpt-3.5-turbo-0301=$mapper_gpt35"
fi
if [ ! -z "$mapper_gpt4" ]; then
  if [ ! -z "$MODEL_MAPPER" ]; then
    MODEL_MAPPER="$MODEL_MAPPER,"
  fi
  MODEL_MAPPER="$MODEL_MAPPER gpt-4=$mapper_gpt4"
fi

# Run the docker container
docker run -d -p 8080:8080 --name=$CONTAINER_NAME \
  --env AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT \
  --env AZURE_OPENAI_MODEL_MAPPER=$MODEL_MAPPER \
  $IMAGE_NAME
