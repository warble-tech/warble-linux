#!/bin/bash
# Mount Vagrant shared folder
mkdir -p /vagrant
mount -t vboxsf vagrant /vagrant || echo "Failed to mount Vagrant shared folder. Is VirtualBox Guest Additions running?"
echo "Vagrant mounted at /vagrant"
