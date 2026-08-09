# Building Warble Linux

## Quick start (any Linux / macOS / CI)

No Arch tools required. Produces **mock** (non-bootable) release artifacts that are non-empty and CI-safe:

```bash
make bake EDITION=1          # minimal
make all-editions            # all four editions → out/
make test-artifacts          # validate ISO / WSL / OVF / box / checksums
make release-check           # lint + all-editions + test-artifacts
```

Or:

```bash
EDITION=4 ./scripts/make-and-bake.sh
MOCK_ONLY=1 EDITION=2 ./scripts/make-and-bake.sh
```

Artifacts land in `out/`:

| Artifact | Description |
|----------|-------------|
| `warble-linux-<edition>-<ver>-<sha>.iso` | Real ISO if mkarchiso succeeds; otherwise mock |
| `warble-linux-wsl2-*.tar.gz` | WSL-style rootfs tarball (mock until full rootfs bake) |
| `warble-linux-*.ovf` | OVF stub for packaging pipelines |
| `warble-linux-*.box` | Vagrant box stub |
| `MANIFEST-*.txt` / `SHA256SUMS-*.txt` | Build metadata + checksums |

## Real bootable ISO (Arch host)

1. Install tools:

   ```bash
   sudo pacman -S archiso
   ```

2. Complete the archiso profile bootloaders (still WIP — see below).

3. Build:

   ```bash
   make bake EDITION=4
   ```

The bake script only calls `mkarchiso` when:

- `mkarchiso` is on `PATH`
- `profile/profiledef.sh` and `profile/pacman.conf` exist
- `profile/syslinux/` **or** `profile/grub/` is present

Otherwise it falls back to mock artifacts automatically.

## Completing the archiso profile

Copy structure from Arch’s official releng profile:

```bash
# On an Arch system with archiso installed:
cp -a /usr/share/archiso/configs/releng/syslinux profile/
cp -a /usr/share/archiso/configs/releng/grub profile/
cp -a /usr/share/archiso/configs/releng/efiboot profile/  # if present
# Then adjust labels / menus for Warble Linux
```

Also verify:

- `profile/packages.x86_64` is generated from `editions/*.packages` (do not hand-edit long-term)
- Live user / network / display defaults under `profile/airootfs/`

## Environment variables

| Variable | Default | Meaning |
|----------|---------|---------|
| `EDITION` | `1` (or dialog) | `1`–`4` |
| `VERSION` | UTC `YYYY.MM.DD` | Version string in filenames |
| `GIT_SHA` | short git HEAD | Embedded in ISO name |
| `OUT_DIR` | `./out` | Artifact directory |
| `WORK_DIR` | `/tmp/warble-linux-work` | Scratch |
| `MOCK_ONLY` | `0` | Force mock path when `1` |

## Optional GCP publish

```bash
DRY_RUN=1 ./scripts/push-to-gcp.sh   # default: print plan only
DRY_RUN=0 ./scripts/push-to-gcp.sh   # requires gcloud + docker auth
```
