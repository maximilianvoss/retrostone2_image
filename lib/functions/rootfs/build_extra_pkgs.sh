#!/usr/bin/env bash

function build_extra_pkgs() {
	declare package_name="csafestring"

  declare -g -r OVERLAY_WORKDIR="${WORKDIR_BASE_TMP}/overlay-workdir-${ARMBIAN_BUILD_UUID}"
  declare -g -r OVERLAY_UPPER="${WORKDIR_BASE_TMP}/overlay-upper-${ARMBIAN_BUILD_UUID}"
  declare -g -r OVERLAY_MERGED="${WORKDIR_BASE_TMP}/overlay-merged-${ARMBIAN_BUILD_UUID}"

  mkdir -p "${OVERLAY_UPPER}"
  mkdir -p "${OVERLAY_WORKDIR}"
  mkdir -p "${OVERLAY_MERGED}"

  mount -t overlay overlay -o lowerdir="${SDCARD}",upperdir="${OVERLAY_UPPER}",workdir="${OVERLAY_WORKDIR}" "${OVERLAY_MERGED}"

  mkdir -p "${OVERLAY_MERGED}/build/${package_name}"

  fetch_from_repo "$GITHUB_SOURCE/maximilianvoss/csafestring" "${package_name}" "tag:v1.8"

  cd "${OVERLAY_MERGED}/build/${package_name}" || exit_with_error "can't change directory"
  cp -R "${SRC}/cache/sources/${package_name}" "${OVERLAY_MERGED}/build/${package_name}"
  cp -R ~/rs2_image/packages/extras-buildpkgs/csafestring/debian "${OVERLAY_MERGED}/build/${package_name}/debian"

  dpkg-buildpackage -b -us -j4 -uc
  find "${OVERLAY_MERGED}/build"
  dpkg -c "${OVERLAY_MERGED}/build/*.deb"

  umount "${OVERLAY_MERGED}"
  rm -rf "${OVERLAY_UPPER}"
  rm -rf "${OVERLAY_WORKDIR}"
  rm -rf "${OVERLAY_MERGED}"
}
