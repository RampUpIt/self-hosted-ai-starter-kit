#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 <tag>"
  exit 1
}

# Check if tag is provided
if [ -z "$1" ]; then
  echo "Error: Tag not provided."
  usage
fi

# Set variables
TAG=$1
IMAGE_NAME="my-n8n-amd-image"
REGISTRY="n8narchipelcontainerregistry.azurecr.io"
RESOURCE_GROUP="archipel-prod"
CONTAINER_APP_NAME="n8napp"

# Step 1: Build the Docker image
echo "Building Docker image..."
docker buildx build --platform linux/amd64 -t ${IMAGE_NAME}:${TAG} .

# Step 2: Tag the Docker image for the Azure Container Registry
echo "Tagging Docker image..."
docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}

# Step 3: Push the Docker image to Azure Container Registry
echo "Pushing Docker image to Azure Container Registry..."
docker push ${REGISTRY}/${IMAGE_NAME}:${TAG}

# Step 4: Update the Azure Container App with the new image
echo "Updating Azure Container App with the new image..."
az containerapp update \
  --name ${CONTAINER_APP_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --image ${REGISTRY}/${IMAGE_NAME}:${TAG}

# Completion message
echo "Deployment complete. Image ${TAG} pushed and deployed to ${CONTAINER_APP_NAME}."
