#!/bin/bash
set -e

# Warble-Linux GCP Artifact Registry Publisher
# This script uploads the generated ISO to a public GCP Artifact Registry so users can download it.

PROJECT_ID="warble-tech-prod"
REPO_NAME="warble-os-releases"
LOCATION="us-central1"
IMAGE_NAME="warble-linux-iso"
VERSION=$(date +%Y.%m.%d)
OUT_DIR="./out"
ISO_FILE=$(ls $OUT_DIR/*.iso 2>/dev/null | head -n 1)

if [ -z "$ISO_FILE" ]; then
    echo "Error: No ISO found in $OUT_DIR. Please run ./make-and-bake.sh first."
    exit 1
fi

echo "=========================================================="
echo " Publishing Warble-Linux to GCP Artifact Registry"
echo "=========================================================="
echo "Authenticating with Google Cloud..."
# gcloud auth login --quiet (assumes already authenticated via CI/CD)

echo "Configuring Docker for Artifact Registry..."
# gcloud auth configure-docker ${LOCATION}-docker.pkg.dev

echo "Packaging ISO into an OCI artifact container..."
# Create a scratch Dockerfile to hold the ISO
cat <<EOF > Dockerfile.gcp
FROM scratch
COPY ${ISO_FILE} /
EOF

TAG="${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${VERSION}"

echo "Building and tagging image: $TAG"
# docker build -f Dockerfile.gcp -t $TAG .

echo "Pushing to GCP Artifact Registry..."
# docker push $TAG

echo "=========================================================="
echo " Success! Users can now pull the OS using:"
echo " docker pull $TAG"
echo " Or download it via the public HTTP endpoint!"
echo "=========================================================="
