#!/usr/bin/env bash
# Warble Linux — Make-and-Bake
# Builds an ISO (real mkarchiso when available) + release artifacts.
# On stock Ubuntu CI (no mkarchiso), produces valid non-empty *mock* artifacts
# so GitHub Releases/upload-artifact never see 0-byte files.
#
# Usage:
#   EDITION=1 ./make-and-bake.sh          # minimal
#   EDITION=4 ./make-and-bake.sh          # full
#   MOCK_ONLY=1 ./make-and-bake.sh        # force mock artifacts
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

VERSION="${VERSION:-$(date -u +%Y.%m.%d)}"
GIT_SHA="${GIT_SHA:-$(git rev-parse --short HEAD 2>/dev/null || echo local)}"
WORK_DIR="${WORK_DIR:-/tmp/warble-linux-work}"
OUT_DIR="${OUT_DIR:-$ROOT/out}"
PROFILE_DIR="$ROOT/profile"
MOCK_ONLY="${MOCK_ONLY:-0}"

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

# ── Edition selection ────────────────────────────────────────────────────────
if [[ -z "${EDITION:-}" ]]; then
  if command -v dialog >/dev/null 2>&1 && [[ -t 0 ]]; then
    EDITION=$(dialog --clear \
      --backtitle "Warble-Linux Sandbox OS Installer" \
      --title "Select Edition to Bake" \
      --menu "Choose sandbox variant:" 16 75 5 \
      1 "Minimal (Terminator Only)" \
      2 "Developer & GenAI (Go, Rust, Python, Node, Ollama hooks)" \
      3 "Cloud-Native (kubectl, helm, container tooling)" \
      4 "Full Edition (All Features Combined)" \
      2>&1 >/dev/tty) || true
    clear || true
  else
    EDITION=1
    log "No TTY/dialog — defaulting EDITION=1 (minimal)"
  fi
fi

case "$EDITION" in
  1|2|3|4) ;;
  *) die "invalid EDITION=$EDITION (use 1-4)" ;;
esac

EDITION_NAME=( "" "minimal" "developer" "cloud-native" "full" )
ENAME="${EDITION_NAME[$EDITION]}"
log "Edition $EDITION ($ENAME)  version=$VERSION  sha=$GIT_SHA"

# ── Packages (Arch official only — no AUR names in CI profile) ─────────────
mkdir -p "$PROFILE_DIR"
PKG_FILE="$PROFILE_DIR/packages.x86_64"

cat > "$PKG_FILE" <<'EOF'
# Base (archiso)
base
linux
linux-firmware
mkinitcpio
syslinux
# Networking / admin
nftables
iproute2
iputils
dhcpcd
sudo
dialog
git
curl
wget
tar
unzip
# GUI minimal
openbox
xorg-server
xorg-xinit
xterm
firefox
ttf-dejavu
terminator
# Guest helpers (optional; ignored if unavailable in build env)
# virtualbox-guest-utils-nox
EOF

case "$EDITION" in
  2)
    log "Baking Developer & GenAI packages..."
    cat >> "$PKG_FILE" <<'EOF'
go
rust
python
python-pip
nodejs
npm
neovim
# Note: ollama / goose / vscodium are not in official Arch repos —
# install via post-boot scripts or AUR on a full build host.
EOF
    ;;
  3)
    log "Baking Cloud-Native packages..."
    cat >> "$PKG_FILE" <<'EOF'
docker
kubectl
helm
# k3s / rancher-cli: install via official install scripts in airootfs hooks
EOF
    ;;
  4)
    log "Baking Full Edition packages..."
    cat >> "$PKG_FILE" <<'EOF'
go
rust
python
python-pip
nodejs
npm
neovim
docker
kubectl
helm
EOF
    ;;
  1) log "Baking Minimal Edition..." ;;
esac

# ── Build ISO ────────────────────────────────────────────────────────────────
rm -rf "$WORK_DIR"
mkdir -p "$OUT_DIR" "$WORK_DIR"
ISO_NAME="warble-linux-${ENAME}-${VERSION}-${GIT_SHA}.iso"
ISO_PATH="$OUT_DIR/$ISO_NAME"

build_real_iso() {
  command -v mkarchiso >/dev/null 2>&1 || return 1
  [[ -f "$PROFILE_DIR/profiledef.sh" ]] || return 1
  [[ -f "$PROFILE_DIR/pacman.conf" ]] || {
    log "profile/pacman.conf missing — cannot run real mkarchiso yet"
    return 1
  }
  log "Running mkarchiso (real ISO)..."
  mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"
  # rename first iso to stable name
  local found
  found=$(ls -1 "$OUT_DIR"/*.iso 2>/dev/null | head -1 || true)
  if [[ -n "$found" && "$found" != "$ISO_PATH" ]]; then
    mv -f "$found" "$ISO_PATH"
  fi
  [[ -s "$ISO_PATH" ]] || return 1
  return 0
}

build_mock_iso() {
  log "Creating non-empty mock ISO artifact (mkarchiso unavailable or MOCK_ONLY=1)"
  local stage="$WORK_DIR/mock-iso-root"
  rm -rf "$stage"
  mkdir -p "$stage/warble-linux"
  cat > "$stage/warble-linux/README.txt" <<EOF
Warble Linux — MOCK ARTIFACT (not a bootable ISO)

Edition:  $EDITION ($ENAME)
Version:  $VERSION
Git:      $GIT_SHA
Built:    $(date -u +%Y-%m-%dT%H:%M:%SZ)

This file is produced on CI runners without archiso.
For a real ISO, run on Arch Linux with:
  pacman -S archiso
  EDITION=$EDITION ./make-and-bake.sh

Or use a full profile with pacman.conf + bootloaders under profile/.
EOF
  cp "$PKG_FILE" "$stage/warble-linux/packages.x86_64" 2>/dev/null || true
  # Prefer real tools; fall back to tar.gz renamed with .iso suffix only if needed
  if command -v genisoimage >/dev/null 2>&1; then
    genisoimage -quiet -o "$ISO_PATH" -V "WARBLE_MOCK" -J -R "$stage"
  elif command -v mkisofs >/dev/null 2>&1; then
    mkisofs -quiet -o "$ISO_PATH" -V "WARBLE_MOCK" -J -R "$stage"
  elif command -v xorriso >/dev/null 2>&1; then
    xorriso -as mkisofs -o "$ISO_PATH" -V "WARBLE_MOCK" -J -R "$stage" >/dev/null 2>&1
  else
    # Portable fallback: compressed payload with .iso extension (still non-empty)
    tar -C "$stage" -czf "$ISO_PATH" warble-linux
  fi
  # Ensure >= 1 byte (GitHub Releases requirement)
  [[ -s "$ISO_PATH" ]] || echo "warble-linux mock" > "$ISO_PATH"
}

if [[ "$MOCK_ONLY" == "1" ]]; then
  build_mock_iso
elif ! build_real_iso; then
  build_mock_iso
fi

# ── Secondary artifacts (always non-empty) ───────────────────────────────────
log "Generating WSL / OVF / Vagrant / manifest artifacts..."

WSL="$OUT_DIR/warble-linux-wsl2-${ENAME}-${VERSION}.tar.gz"
OVF="$OUT_DIR/warble-linux-${ENAME}-${VERSION}.ovf"
BOX="$OUT_DIR/warble-linux-${ENAME}-${VERSION}.box"
MANIFEST="$OUT_DIR/MANIFEST-${ENAME}-${VERSION}.txt"
SHAFILE="$OUT_DIR/SHA256SUMS-${ENAME}-${VERSION}.txt"

# WSL rootfs mock: tarball with a rootfs tree (not empty)
WSL_STAGE="$WORK_DIR/wsl-root"
rm -rf "$WSL_STAGE"
mkdir -p "$WSL_STAGE/etc" "$WSL_STAGE/usr/local/bin" "$WSL_STAGE/root"
echo "Warble Linux WSL mock rootfs edition=$ENAME version=$VERSION" > "$WSL_STAGE/etc/warble-release"
echo "ID=warble-linux" > "$WSL_STAGE/etc/os-release"
echo "NAME=\"Warble Linux\"" >> "$WSL_STAGE/etc/os-release"
echo "VERSION=$VERSION" >> "$WSL_STAGE/etc/os-release"
printf '#!/bin/sh\necho warble-linux wsl mock\n' > "$WSL_STAGE/usr/local/bin/warble-hello"
chmod +x "$WSL_STAGE/usr/local/bin/warble-hello"
tar -C "$WSL_STAGE" -czf "$WSL" .

# OVF (valid-enough XML stub for packaging pipelines)
cat > "$OVF" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Warble Linux OVF stub — attach real disk after full image bake -->
<Envelope xmlns="http://schemas.dmtf.org/ovf/envelope/1"
          xmlns:ovf="http://schemas.dmtf.org/ovf/envelope/1"
          xmlns:rasd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData"
          xmlns:vssd="http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData">
  <References>
    <File ovf:id="iso" ovf:href="$(basename "$ISO_PATH")" ovf:size="$(stat -c%s "$ISO_PATH" 2>/dev/null || echo 0)"/>
  </References>
  <DiskSection>
    <Info>Warble Linux Live ISO reference</Info>
  </DiskSection>
  <VirtualSystem ovf:id="Warble-Linux-${ENAME}">
    <Info>Warble Linux ${ENAME} ${VERSION}</Info>
    <Name>Warble-Linux-${ENAME}</Name>
  </VirtualSystem>
</Envelope>
EOF

# Vagrant box: tar of metadata + stub (must be non-empty .box)
BOX_STAGE="$WORK_DIR/box"
rm -rf "$BOX_STAGE"
mkdir -p "$BOX_STAGE"
cat > "$BOX_STAGE/metadata.json" <<EOF
{"provider":"virtualbox","format":"ovf","version":"0"}
EOF
echo "Warble Linux Vagrant box stub edition=$ENAME version=$VERSION" > "$BOX_STAGE/Vagrantfile"
echo "# Placeholder — replace with real disk.vmdk after full bake" > "$BOX_STAGE/box.ovf"
tar -C "$BOX_STAGE" -czf "$BOX" metadata.json Vagrantfile box.ovf

# Manifest + checksums
{
  echo "Warble Linux build manifest"
  echo "edition=$ENAME ($EDITION)"
  echo "version=$VERSION"
  echo "git=$GIT_SHA"
  echo "built_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "host=$(uname -a)"
  echo "mock=$( [[ ! -x "$(command -v mkarchiso 2>/dev/null)" || "$MOCK_ONLY" == "1" ]] && echo yes || echo no )"
  echo "iso=$(basename "$ISO_PATH")"
  echo "wsl=$(basename "$WSL")"
  echo "ovf=$(basename "$OVF")"
  echo "box=$(basename "$BOX")"
} > "$MANIFEST"

(
  cd "$OUT_DIR"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$(basename "$ISO_PATH")" "$(basename "$WSL")" "$(basename "$OVF")" "$(basename "$BOX")" > "$(basename "$SHAFILE")"
  else
    shasum -a 256 "$(basename "$ISO_PATH")" "$(basename "$WSL")" "$(basename "$OVF")" "$(basename "$BOX")" > "$(basename "$SHAFILE")"
  fi
)

# Fail hard if anything is still empty
log "Artifact sizes:"
fail=0
for f in "$ISO_PATH" "$WSL" "$OVF" "$BOX" "$MANIFEST" "$SHAFILE"; do
  if [[ ! -s "$f" ]]; then
    echo "  EMPTY: $f" >&2
    fail=1
  else
    sz=$(wc -c <"$f" | tr -d ' ')
    echo "  OK ($sz bytes): $(basename "$f")"
  fi
done
[[ "$fail" -eq 0 ]] || die "one or more artifacts are empty — GitHub Releases would reject them"

log "Build complete → $OUT_DIR"
ls -la "$OUT_DIR"
echo ""
echo "Test: boot ISO in QEMU/VirtualBox, or import WSL mock with care."
echo "Public MCP (unrelated ops demo): https://mcp.warbleoss.org"
