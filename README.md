# Warble Linux

![Warble Linux Logo](./logo.jpg)

Sandbox-oriented Linux live image for isolated testing, development, and cloud-native workflows.  
Part of the Warble ecosystem · MCP ops demo: [mcp.warbleoss.org](https://mcp.warbleoss.org)

## Features

| Area | Notes |
|------|--------|
| **Editions** | 1 Minimal · 2 Developer · 3 Cloud-Native · 4 Full |
| **GUI** | Openbox + Firefox (when real ISO is baked) |
| **Artifacts** | ISO · WSL `tar.gz` · OVF stub · Vagrant `.box` · `MANIFEST` · `SHA256SUMS` |
| **CI** | GitHub Actions uploads artifacts + prerelease on `main` |

## What was wrong (fixed)

CI failed with:

```text
ReleaseAsset size must be greater than or equal to 1
```

because mock ISO/`.box` used `touch` (**0-byte** files). GitHub Releases reject empty assets.

Also: Ubuntu runners have **no `mkarchiso`**, package list mixed **AUR-only** names (`vscodium-bin`, `goose-agent`, `k3s`), and the archiso **profile was incomplete** (missing `pacman.conf` / bootloaders for a real bake).

## How to build

```bash
# Mock / CI-safe (works on Ubuntu/macOS without Arch)
EDITION=1 ./make-and-bake.sh
ls -la out/

# Real ISO (Arch Linux host with archiso)
sudo pacman -S archiso
EDITION=4 ./make-and-bake.sh
```

Interactive menu (needs `dialog` + TTY):

```bash
./make-and-bake.sh
```

## CI artifacts (GitHub-hosted public runners)

CI uses **GitHub-hosted `ubuntu-latest` only** — no self-hosted runners.

On every push to `main`:

1. `make-and-bake.sh` runs (edition 4 by default)
2. `actions/upload-artifact` stores `out/*`
3. A **prerelease** is created with non-empty assets

Workflow: [`.github/workflows/publish.yml`](.github/workflows/publish.yml)

> Real bootable ISOs need `mkarchiso` (Arch). Public Ubuntu runners produce **valid mock** packages until we add a Docker/Arch bake job on the same public runners.

## Mount helpers (inside live image)

Under `/usr/local/bin` when booted from a full image:

- `mount-wsl.sh`
- `mount-vagrant.sh`
- `mount-filestorage.sh`

## Status

| Path | Status |
|------|--------|
| Mock artifacts + CI release | **Working** after size fix |
| Full bootable archiso profile | **WIP** — need syslinux/grub under `profile/` like releng |
| GCP Artifact Registry push | Script stub (`push-to-gcp.sh`) — not wired in CI |

## License

See [LICENSE](LICENSE).
