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
  #InstallEmulationStation
  #InstallRetroPie
	case $RELEASE in
		stretch)
			# your code here
			# InstallOpenMediaVault # uncomment to get an OMV 4 image
			;;
		buster)
			# your code here
			;;
		bullseye)
			# your code here
			;;
		bionic)
			# your code here
			;;
		focal)
			# your code here
			;;
	esac
} # Main

InstallEmulationStation() {
  local tmp_dir libsdl2_dir
  tmp_dir=$(mktemp -d)
  chmod 700 ${tmp_dir}

  git clone --recursive https://github.com/RetroPie/EmulationStation.git ${tmp_dir}
  pushd ${tmp_dir}
  mkdir build
  cd build
  cmake ..
  make -j2
  make install
  popd
}

Main "$@"
