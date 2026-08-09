#!/bin/bash
# Build all four editions into OUT_DIR (default: ./out).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/out}"
export OUT_DIR

mkdir -p "$OUT_DIR"
for ed in 1 2 3 4; do
  echo "======== EDITION=$ed ========"
  EDITION="$ed" "$ROOT/scripts/make-and-bake.sh"
done

echo "======== all editions complete ========"
ls -la "$OUT_DIR"
