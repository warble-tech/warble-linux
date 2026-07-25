#!/bin/bash
# Mount WSLv2 Windows file system
mkdir -p /mnt/wsl
mount -t 9p -o trans=virtio,version=9p2000.L,msize=512000 C:\\ /mnt/wsl || echo "Failed to mount WSLv2, are you running under WSL?"
echo "WSLv2 mounted at /mnt/wsl"
