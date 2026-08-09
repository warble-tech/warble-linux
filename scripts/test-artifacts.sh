#!/bin/bash
# Validate warble-linux out/ artifacts (mock or real).
# Exit 0 only if every check passes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$ROOT/out}"
# Editions expected after `make all-editions`
EDITIONS=(minimal developer cloud-native full)
# Minimum non-empty size (GitHub Releases require >= 1 byte; we require more signal)
MIN_BYTES=32
FAIL=0

log() { printf '==> %s\n' "$*"; }
ok() { printf '  OK  %s\n' "$*"; }
bad() { printf '  FAIL %s\n' "$*" >&2; FAIL=1; }

[[ -d "$OUT_DIR" ]] || { echo "error: missing $OUT_DIR — run make all-editions first" >&2; exit 1; }

log "Testing artifacts in $OUT_DIR"

# ── Per-edition file presence + size ───────────────────────────────────────
for ename in "${EDITIONS[@]}"; do
  log "Edition: $ename"

  # ISO: warble-linux-<edition>-<version>-<sha>.iso (glob)
  mapfile -t isos < <(find "$OUT_DIR" -maxdepth 1 -type f -name "warble-linux-${ename}-*.iso" ! -name '*.ovf' 2>/dev/null | sort)
  if (( ${#isos[@]} == 0 )); then
    bad "no ISO for $ename"
  else
    iso="${isos[-1]}"
    sz=$(wc -c <"$iso" | tr -d ' ')
    if (( sz < MIN_BYTES )); then
      bad "ISO too small ($sz): $(basename "$iso")"
    else
      ok "ISO $(basename "$iso") ($sz bytes)"
    fi
    # Prefer file(1) magic; mock may be ISO9660 or gzip (tar fallback)
    if command -v file >/dev/null 2>&1; then
      ft=$(file -b "$iso" || true)
      if [[ $ft == *ISO* || $ft == *ISO\ 9660* || $ft == *gzip* || $ft == *archive* || $ft == *data* ]]; then
        ok "ISO type: $ft"
      else
        bad "unexpected ISO type: $ft"
      fi
    fi
  fi

  wsl=$(find "$OUT_DIR" -maxdepth 1 -type f -name "warble-linux-wsl2-${ename}-*.tar.gz" | sort | tail -1 || true)
  if [[ -z "$wsl" || ! -s "$wsl" ]]; then
    bad "missing/empty WSL tarball for $ename"
  else
    ok "WSL $(basename "$wsl") ($(wc -c <"$wsl" | tr -d ' ') bytes)"
    if ! tar -tzf "$wsl" >/dev/null 2>&1; then
      bad "WSL tarball not readable: $(basename "$wsl")"
    else
      if tar -tzf "$wsl" | grep -q 'etc/os-release\|etc/warble-release'; then
        ok "WSL contains release metadata"
      else
        bad "WSL missing etc/*release entries"
      fi
    fi
  fi

  ovf=$(find "$OUT_DIR" -maxdepth 1 -type f -name "warble-linux-${ename}-*.ovf" | sort | tail -1 || true)
  if [[ -z "$ovf" || ! -s "$ovf" ]]; then
    bad "missing/empty OVF for $ename"
  else
    if grep -q 'Envelope\|VirtualSystem' "$ovf"; then
      ok "OVF $(basename "$ovf")"
    else
      bad "OVF does not look like OVF XML: $(basename "$ovf")"
    fi
  fi

  box=$(find "$OUT_DIR" -maxdepth 1 -type f -name "warble-linux-${ename}-*.box" | sort | tail -1 || true)
  if [[ -z "$box" || ! -s "$box" ]]; then
    bad "missing/empty .box for $ename"
  else
    if tar -tzf "$box" 2>/dev/null | grep -q 'metadata.json'; then
      ok "box $(basename "$box") has metadata.json"
    else
      bad "box missing metadata.json: $(basename "$box")"
    fi
  fi

  man=$(find "$OUT_DIR" -maxdepth 1 -type f -name "MANIFEST-${ename}-*.txt" | sort | tail -1 || true)
  if [[ -z "$man" || ! -s "$man" ]]; then
    bad "missing MANIFEST for $ename"
  else
    if grep -q "^edition=${ename}" "$man" && grep -q '^mock=' "$man"; then
      ok "MANIFEST $(basename "$man") ($(grep '^mock=' "$man"))"
    else
      bad "MANIFEST incomplete: $(basename "$man")"
    fi
  fi

  sha=$(find "$OUT_DIR" -maxdepth 1 -type f -name "SHA256SUMS-${ename}-*.txt" | sort | tail -1 || true)
  if [[ -z "$sha" || ! -s "$sha" ]]; then
    bad "missing SHA256SUMS for $ename"
  else
    (
      cd "$OUT_DIR"
      if command -v sha256sum >/dev/null 2>&1; then
        # Only verify lines that reference files present (ISO names may drift with git sha)
        while read -r hash name; do
          [[ -z "${name:-}" ]] && continue
          if [[ -f "$name" ]]; then
            echo "$hash  $name" | sha256sum -c - >/dev/null || exit 1
          fi
        done <"$(basename "$sha")"
      fi
    ) && ok "SHA256SUMS verify for existing files ($(basename "$sha"))" || bad "SHA256SUMS mismatch for $ename"
  fi
done

# ── Global guards ────────────────────────────────────────────────────────────
log "Global guards"
zeros=$(find "$OUT_DIR" -type f -size 0 2>/dev/null | wc -l | tr -d ' ')
if (( zeros > 0 )); then
  bad "found $zeros zero-byte files (GitHub Releases would reject)"
  find "$OUT_DIR" -type f -size 0 -print >&2 || true
else
  ok "no zero-byte files"
fi

count=$(find "$OUT_DIR" -type f | wc -l | tr -d ' ')
ok "$count files under out/"

if (( FAIL != 0 )); then
  echo ""
  echo "ARTIFACT TESTS FAILED" >&2
  exit 1
fi

echo ""
log "All artifact tests passed"
exit 0
