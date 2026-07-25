#!/bin/bash
set -e

# Build script for Warble-Linux Sandbox OS
# Requires: archiso, qemu (for OVF conversion if needed), virtualbox (optional)

PROFILE_DIR="./profile"
WORK_DIR="/tmp/warble-linux-work"
OUT_DIR="./out"

echo "==> Cleaning previous builds..."
rm -rf "$WORK_DIR"
mkdir -p "$OUT_DIR"

echo "==> Cloning devops-exercises into skel..."
# Clone devops-exercises into the skeleton directory so every new user (or live user) gets it
if [ ! -d "$PROFILE_DIR/airootfs/etc/skel/devops-exercises/.git" ]; then
    git clone https://github.com/bregman-arie/devops-exercises.git "$PROFILE_DIR/airootfs/etc/skel/devops-exercises"
fi

echo "==> Building Warble-Linux ISO..."
# Run mkarchiso
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

echo "==> ISO build complete! Located in $OUT_DIR"

# To generate an OVF, one typically creates a VM using the ISO, installs it, and exports it.
# Since this is a Live OS (no persistent layer), we can just bundle the ISO as a CD-ROM inside an OVF using VirtualBox CLI, or recommend the user to boot the ISO directly.
# 
# Example VBoxManage commands to create a VM for the Live ISO and export to OVF:
# VBoxManage createvm --name "Warble-Linux" --ostype "Linux26_64" --register
# VBoxManage modifyvm "Warble-Linux" --memory 4096 --vram 128
# VBoxManage storagectl "Warble-Linux" --name "IDE" --add ide
# VBoxManage storageattach "Warble-Linux" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$OUT_DIR"/warble-linux-*.iso
# VBoxManage export "Warble-Linux" --output "$OUT_DIR/Warble-Linux.ovf"
#
echo "==> To generate OVF, use the VBoxManage snippet in this script."
