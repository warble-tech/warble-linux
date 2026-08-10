# Bootloaders (syslinux / grub / efiboot)

Warble Linux live ISOs use the same boot modes as Arch’s official install
medium (archiso **releng**):

- BIOS: syslinux (MBR + El Torito)
- UEFI: GRUB (ESP + El Torito) and efiboot loader entries

## Source

Trees under `profile/syslinux`, `profile/grub`, and `profile/efiboot` are
adapted from:

https://github.com/archlinux/archiso → `configs/releng/`

See `profile/BOOTLOADERS.NOTICE`. Upstream is **GPL-3.0-or-later**.

## Branding

User-visible menu titles say **Warble Linux live sandbox**.  
Do **not** rename archiso kernel parameters (`archisobasedir`,
`archisosearchuuid`, `%INSTALL_DIR%`, …) — `mkarchiso` and the live initramfs
depend on them.

## Refresh

```bash
./scripts/sync-bootloaders.sh
```

## Real vs mock

With these trees present, `scripts/make-and-bake.sh` will call `mkarchiso`
when it is installed. On Ubuntu CI (no archiso), the script still falls back
to **mock** artifacts. For a real ISO on a non-Arch host, use Docker:

```bash
EDITION=1 ./scripts/docker-bake.sh
```
