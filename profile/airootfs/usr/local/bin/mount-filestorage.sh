#!/bin/bash
# Mount generic file storage
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <source_ip:/path> <mount_point>"
  exit 1
fi
mkdir -p "$2"
mount -t nfs "$1" "$2" || echo "Failed to mount NFS file storage."
echo "Mounted $1 at $2"
