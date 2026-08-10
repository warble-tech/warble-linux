# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- (none yet)

## [0.2.0] — 2026-08-10

### Added

- Semver **`VERSION`** file + `scripts/version.sh` (`print` / `bump` / `nightly` / `tag`).
- GitHub Actions **Release** workflow (tag `vX.Y.Z` or dispatch with bump/set).
- Nightly prereleases use semver tags: `vX.Y.Z-nightly.N`.
- `scripts/test-artifacts.sh` + `make test-artifacts` / `make release-check`.
- CI `test-matrix` job before prerelease/release.
- archiso **releng** bootloaders under `profile/{syslinux,grub,efiboot}` (rebranded)
  + `scripts/sync-bootloaders.sh`, `scripts/docker-bake.sh`, `docs/bootloaders.md`.
- README releases & versioning section.

### Changed

- **Open-source redesign**: modular `editions/` package lists, `scripts/` layout,
  `Makefile`, architecture/building docs, CONTRIBUTING / CoC / SECURITY.
- Bake prefers `VERSION` file for artifact filenames (over date-only).
- Bake refuses real `mkarchiso` when syslinux/grub trees are missing
  (avoids half-broken profiles) and falls back to mock artifacts.

### Fixed

- (Prior) GitHub Releases reject 0-byte assets — mock path always emits non-empty files.

## [0.1.0] — 2026-08

- Initial public packaging: mock bake, four editions, prerelease workflow,
  airootfs helpers and Openbox live skeleton.
