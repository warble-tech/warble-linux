#!/bin/bash
set -e

# Script to initialize and push to the warble-tech organization repository

echo "Initializing git repository for warble-linux..."
git init

echo "Adding all files..."
git add .

echo "Committing initial state..."
git commit -m "Initial commit: Warble-Linux Sandbox OS (GPLv2)" || echo "Nothing to commit"

echo "Adding remote warble-tech..."
git remote add origin https://github.com/warble-tech/warble-linux.git || echo "Remote origin already exists"

echo "========================================================="
echo "Git repository is ready. To push to the warble-tech org:"
echo "  git push -u origin main"
echo "========================================================="
