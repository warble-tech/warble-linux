# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- **Open-source redesign**: modular `editions/` package lists, `scripts/` layout,
  `Makefile`, architecture/building docs, CONTRIBUTING / CoC / SECURITY.
- Bake script refuses real `mkarchiso` when syslinux/grub trees are missing
  (avoids half-broken profiles) and falls back to mock artifacts.
- CI builds all four editions via matrix; root `make-and-bake.sh` remains a
  compatibility wrapper.

### Fixed

- (Prior) GitHub Releases reject 0-byte assets — mock path always emits non-empty files.

## [0.1.0] — 2026-08

- Initial public packaging: mock bake, four editions, prerelease workflow,
  airootfs helpers and Openbox live skeleton.
