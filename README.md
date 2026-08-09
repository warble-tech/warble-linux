# Warble Linux

<p align="center">
  <img src="assets/logo.jpg" alt="Warble Linux" width="160"/>
</p>

**Sandbox-oriented Linux live images** for isolated testing, learning, and
cloud-native workflows — open source, rebuildable, multi-format.

[![Build artifacts](https://github.com/warble-tech/warble-linux/actions/workflows/publish.yml/badge.svg)](https://github.com/warble-tech/warble-linux/actions/workflows/publish.yml)
[![License: GPL-2.0](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](LICENSE)

Part of the Warble ecosystem · MCP ops demo: [mcp.warbleoss.org](https://mcp.warbleoss.org)

---

## Why Warble Linux?

| You want… | Warble gives you… |
|-----------|-------------------|
| A disposable lab | Live-oriented images; RAM-first sandbox mindset |
| Clear package choices | Four **editions** with reviewable package lists |
| CI-friendly artifacts | ISO · WSL tarball · OVF · Vagrant `.box` · checksums |
| Open governance | GPL-2.0, CoC, security policy, contributing guide |

This is **not** a full daily-driver desktop (see [Omarchy](https://omarchy.org) for that style of distro). Warble is an **artifact factory + live profile** for sandboxes.

## Editions

| # | Name | Focus |
|---|------|--------|
| 1 | **Minimal** | Openbox + Firefox + Terminator |
| 2 | **Developer** | Go, Rust, Python, Node, Neovim, CLI tools |
| 3 | **Cloud-Native** | Docker, kubectl, helm |
| 4 | **Full** | Developer + Cloud-Native |

Package sources of truth: [`editions/`](editions/). Details: [docs/editions.md](docs/editions.md).

## Quick start

```bash
git clone https://github.com/warble-tech/warble-linux.git
cd warble-linux

make bake EDITION=1       # one edition
make all-editions         # 1–4 → out/
make test-artifacts       # validate ISO / WSL / OVF / box / checksums
make release-check        # lint + all editions + artifact tests
make check                # lint + mock minimal bake
```

On Ubuntu/macOS (no `mkarchiso`), builds produce **valid non-empty mock** packages
suitable for CI and release pipelines. Real bootable ISOs need Arch + a complete
archiso profile — see [docs/building.md](docs/building.md).

```bash
# Arch host, once profile bootloaders exist:
sudo pacman -S archiso
make bake EDITION=4
```

## Repository layout

```text
editions/     # package lists (edit these)
profile/      # archiso airootfs + profiledef
scripts/      # make-and-bake, multi-edition, optional GCP push
docs/         # architecture, building, editions
assets/       # branding
out/          # build products (gitignored)
```

## CI

GitHub-hosted **`ubuntu-latest`** only (no self-hosted runners).

On push to `main` / PRs / manual dispatch:

1. Matrix bake of editions **1–4**
2. Upload artifacts
3. On `main`, create a **prerelease** with non-empty assets

Workflow: [`.github/workflows/publish.yml`](.github/workflows/publish.yml)

> Public runners do not ship `mkarchiso`. Until bootloaders land under `profile/`,
> CI ships **mock** packages (see each `MANIFEST-*.txt`).

## Live helpers (full image goal)

Under `/usr/local/bin` when the live rootfs is complete:

- `mount-wsl.sh` · `mount-vagrant.sh` · `mount-filestorage.sh`

## Status

| Area | Status |
|------|--------|
| Mock artifacts + CI prerelease | **Working** |
| Modular editions + Makefile | **Working** |
| Full bootable archiso (syslinux/grub) | **WIP** — [docs/building.md](docs/building.md) |
| Real WSL / Vagrant disks | Stubs |
| GCP registry push | Optional (`scripts/push-to-gcp.sh`, `DRY_RUN=1` default) |

## Contributing

We welcome issues and PRs. Start here:

- [CONTRIBUTING.md](CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- [SECURITY.md](SECURITY.md)
- [SUPPORT.md](SUPPORT.md)

## License

Warble Linux is free software under the **GNU General Public License v2.0**.
See [LICENSE](LICENSE).

Third-party packages inside a built image remain under their own licenses
(Arch Linux and upstream projects).
