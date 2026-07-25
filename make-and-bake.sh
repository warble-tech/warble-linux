#!/bin/bash
set -e

# Warble-Linux Make-and-Bake Installer
# Requires: dialog, mkarchiso

# 1. Ask the user which edition to build
EDITION=$(dialog --clear \
                 --backtitle "Warble-Linux Sandbox OS Installer" \
                 --title "Select Edition to Bake" \
                 --menu "Choose your self-destructing sandbox variant:" 16 75 5 \
                 1 "Minimal (Terminator Only)" \
                 2 "Developer & GenAI (Atom/VSCode, Go, Rust, Python, Node, Ollama, Goose)" \
                 3 "Cloud-Native (K3s, Rancher Dashboard, Skaffold)" \
                 4 "Full Edition (All Features Combined)" \
                 2>&1 >/dev/tty)

clear

PROFILE_DIR="./profile"
mkdir -p "$PROFILE_DIR"
PKG_FILE="$PROFILE_DIR/packages.x86_64"

# Base packages common to all editions
cat <<EOF > "$PKG_FILE"
base
linux
linux-firmware
mkinitcpio
nftables
iproute2
sudo
dialog
sway
swaybg
xorg-xwayland
wl-clipboard
virtualbox-guest-utils-nox
terminator
EOF

case $EDITION in
    1)
        echo "==> Baking Minimal Edition..."
        ;;
    2)
        echo "==> Baking Developer & GenAI Edition..."
        cat <<EOF >> "$PKG_FILE"
go
rust
python
nodejs
npm
vscodium-bin
ollama
goose-agent
EOF
        ;;
    3)
        echo "==> Baking Cloud-Native Edition..."
        cat <<EOF >> "$PKG_FILE"
k3s
containerd
kubectl
helm
skaffold
rancher-cli
firefox
EOF
        ;;
    4)
        echo "==> Baking Full Edition..."
        cat <<EOF >> "$PKG_FILE"
go
rust
python
nodejs
npm
vscodium-bin
ollama
goose-agent
k3s
containerd
kubectl
helm
skaffold
rancher-cli
firefox
EOF
        ;;
    *)
        echo "Build cancelled."
        exit 1
        ;;
esac

echo "==> Packages configured. Proceeding to build ISO..."
WORK_DIR="/tmp/warble-linux-work"
OUT_DIR="./out"

rm -rf "$WORK_DIR"
mkdir -p "$OUT_DIR"

mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

echo "==> Build complete! ISO located in $OUT_DIR"
echo ""
echo "======================================================"
echo "To test in isolation:"
echo "1. Boot the generated ISO in a VM (VirtualBox/QEMU)."
echo "2. Mount your code workspace into the Sandbox OS."
echo "   (e.g., VirtualBox Shared Folders mount as vboxsf)"
echo "3. Work in absolute privacy. All data is cached in RAM."
echo "4. On shutdown, everything self-destructs."
echo "======================================================"
