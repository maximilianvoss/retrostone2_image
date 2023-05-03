#!/usr/bin/env bash

function build_extra_pkg() {
	declare package_name=$1
	declare package_repo=$2
	declare package_ref=$3
	declare package_overlay=$4

  # working directories
  declare -g -r OVERLAY_WORKDIR="${WORKDIR_BASE_TMP}/overlay-workdir-${ARMBIAN_BUILD_UUID}"
  declare -g -r OVERLAY_UPPER="${WORKDIR_BASE_TMP}/overlay-upper-${ARMBIAN_BUILD_UUID}"
  declare -g -r OVERLAY_MERGED="${WORKDIR_BASE_TMP}/overlay-merged-${ARMBIAN_BUILD_UUID}"

  mkdir -p "${OVERLAY_UPPER}"
  mkdir -p "${OVERLAY_WORKDIR}"
  mkdir -p "${OVERLAY_MERGED}"

  # mount & directory setup
  mount -t overlay overlay -o lowerdir="${SDCARD}",upperdir="${OVERLAY_UPPER}",workdir="${OVERLAY_WORKDIR}" "${OVERLAY_MERGED}"
  mkdir -p "${OVERLAY_MERGED}/build"

  # fetch source
  fetch_from_repo "${package_repo]}" "${package_name}" "${package_ref}"

  # build prep
  cp -R "${SRC}/cache/sources/${package_name}" "${OVERLAY_MERGED}/build"
  cd "${OVERLAY_MERGED}/build/${package_name}" || exit_with_error "can't change directory"
  cp -R $package_overlay/* "${OVERLAY_MERGED}/build/${package_name}"

  # Setting up Toolchain
  if dpkg-architecture -e "${ARCH}"; then
		display_alert "Native compilation" "target ${ARCH} on host $(dpkg --print-architecture)"
	else
		display_alert "Cross compilation" "target ${ARCH} on host $(dpkg --print-architecture)"
		toolchain=$(find_toolchain "$KERNEL_COMPILER" "$KERNEL_USE_GCC")
		[[ -z $toolchain ]] && exit_with_error "Could not find required toolchain" "${KERNEL_COMPILER}gcc $KERNEL_USE_GCC"
	fi
  export CC=${KERNEL_COMPILER}gcc
  export CXX=${KERNEL_COMPILER}gcc
  export CPP=${KERNEL_COMPILER}cpp
  export LD=${KERNEL_COMPILER}ld

  # Do the build in overlay dir
  chroot "${OVERLAY_MERGED}"
  run_host_command_logged_raw dpkg --add-architecture "${ARCH}"
  run_host_command_logged_raw fakeroot dpkg-buildpackage -b -us -j4 -uc --host-arch "${ARCH}"
  run_host_command_logged_raw find "${OVERLAY_MERGED}/build"
  run_host_command_logged_raw dpkg -c "${OVERLAY_MERGED}"/build/*.deb
  mv "${OVERLAY_MERGED}"/build/*.deb "${DEB_STORAGE}"

  # clean up
  umount "${OVERLAY_MERGED}"
  rm -rf "${OVERLAY_UPPER}"
  rm -rf "${OVERLAY_WORKDIR}"
  rm -rf "${OVERLAY_MERGED}"
}

function build_extra_pkgs() {
  build_extra_pkg csafestring ${GITHUB_SOURCE}/maximilianvoss/csafestring "tag:v1.8" ~/rs2_image/packages/extras-buildpkgs/csafestring/debian
}