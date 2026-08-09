# archiso profile

This directory is an [archiso](https://wiki.archlinux.org/title/Archiso) profile.

| Path | Role |
|------|------|
| `profiledef.sh` | ISO metadata, boot modes, squashfs options |
| `pacman.conf` | pacman config used during `mkarchiso` |
| `packages.x86_64` | **Generated** by `scripts/make-and-bake.sh` from `editions/` |
| `airootfs/` | Overlay root filesystem for the live image |

## WIP

Copy `syslinux/` and `grub/` (and related EFI bits) from Arch’s **releng** profile
before a real bake will succeed. See [docs/building.md](../docs/building.md).
