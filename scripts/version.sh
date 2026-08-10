#!/bin/bash
# Semver helpers for Warble Linux.
# Usage:
#   ./scripts/version.sh print
#   ./scripts/version.sh bump patch|minor|major
#   ./scripts/version.sh set 1.2.3
#   ./scripts/version.sh tag            # prints vX.Y.Z from VERSION
#   ./scripts/version.sh nightly [N]    # prints vX.Y.Z-nightly.N
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT/VERSION"

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

read_version() {
  [[ -f "$VERSION_FILE" ]] || die "missing $VERSION_FILE"
  local v
  v=$(tr -d '[:space:]' <"$VERSION_FILE")
  [[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "invalid VERSION='$v' (want X.Y.Z)"
  printf '%s' "$v"
}

write_version() {
  local v="$1"
  [[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "invalid version '$v'"
  printf '%s\n' "$v" >"$VERSION_FILE"
}

bump() {
  local part="$1" v major minor patch
  v=$(read_version)
  IFS=. read -r major minor patch <<<"$v"
  case "$part" in
    major) major=$((major + 1)); minor=0; patch=0 ;;
    minor) minor=$((minor + 1)); patch=0 ;;
    patch) patch=$((patch + 1)) ;;
    *) die "bump part must be major|minor|patch (got $part)" ;;
  esac
  write_version "${major}.${minor}.${patch}"
  read_version
}

cmd="${1:-print}"
case "$cmd" in
  print)
    read_version
    echo
    ;;
  tag)
    echo "v$(read_version)"
    ;;
  nightly)
    n="${2:-0}"
    [[ $n =~ ^[0-9]+$ ]] || die "nightly build number must be integer"
    echo "v$(read_version)-nightly.${n}"
    ;;
  set)
    [[ -n "${2:-}" ]] || die "usage: version.sh set X.Y.Z"
    write_version "$2"
    echo "$2"
    ;;
  bump)
    [[ -n "${2:-}" ]] || die "usage: version.sh bump patch|minor|major"
    bump "$2"
    echo
    ;;
  *)
    die "unknown command: $cmd (print|tag|nightly|set|bump)"
    ;;
esac
