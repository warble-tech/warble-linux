# Warble Linux

![Warble Linux Logo](./logo.jpg)

Welcome to **Warble-Verse**! Warble Linux is a sandbox operating system built for isolated testing, development, and cloud-native workflows.

## Features
- **Multiple Editions**: Minimal, Developer & GenAI, Cloud-Native, and Full Edition.
- **GUI**: Openbox with DuckDuckGo via Firefox.
- **Artifacts**: Automatically exports WSLv2 (`tar.gz`), OVF (`ovf`), and Vagrant (`box`) images!
- **Self-Destructing**: Everything is built in a RAM disk and self-destructs upon shutdown.

## How to Build
Run `./make-and-bake.sh` to build the ISO and mock artifacts.

## Mount Helper Scripts
When booted, check `/usr/local/bin` for helper scripts to mount your storage:
- `mount-wsl.sh`: For mounting WSLv2 rootfs.
- `mount-vagrant.sh`: For mounting Vagrant shared folders.
- `mount-filestorage.sh`: For general file storage mounting.
