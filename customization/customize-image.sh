#!/bin/bash
#
# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
  if 	[[ $BOARD = retrostone2 ]]; then
    PatchEmulationStationConfig
    InstallController
    RetropieSkeleton
  fi
}

PatchEmulationStationConfig() {
  sed -i 's/\/root/~/g' /etc/emulationstation/es_systems.cfg
}

InstallController() {
  mkdir -p /usr/local/lib/python2.7/
  tar -xvzf /tmp/overlay/retrostone2-python-packages.tar.gz -C /usr/local/lib/python2.7/

  cp /tmp/overlay/retrostone2-controller.cfg /opt/retropie/configs/all/retroarch/autoconfig/
  cp /tmp/overlay/retrostone2-retroarch.cfg /opt/retropie/configs/all/retroarch.cfg

  cp /tmp/overlay/retrostone2-gpio-controller.py /usr/bin/
  chmod 755 /usr/bin/retrostone2-gpio-controller.py

  cp /tmp/overlay/retrostone2-controller.service /etc/systemd/system/
  chmod 644 /etc/systemd/system/retrostone2-controller.service
}

RetropieSkeleton() {
  cp -R /root/RetroPie /etc/skel
}

Main "$@"
