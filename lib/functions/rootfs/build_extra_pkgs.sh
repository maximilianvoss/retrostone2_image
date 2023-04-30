#!/usr/bin/env bash

build_extra_pkgs() {
	: "${artifact_version:?artifact_version is not set}"

	declare package_name="csafestring"

	declare cleanup_id="" tmp_dir=""
  prepare_temp_dir_in_workdir_and_schedule_cleanup package_name cleanup_id tmp_dir # namerefs

  mkdir -p "${tmp_dir}/${package_name}"

  fetch_from_repo "$GITHUB_SOURCE/maximilianvoss/csafestring" package_name "tag:v1.8"

  cd "${tmp_dir}/${package_name}" || exit_with_error "can't change directory"
  cp -R ~/rs2_image/packages/extras-buildpkgs/csafestring/* ${tmp_dir}/${package_name}

	fakeroot_dpkg_deb_build "${tmp_dir}/${package_name}" "${DEB_STORAGE}"

	done_with_temp_dir "${cleanup_id}" # changes cwd to "${SRC}" and fires the cleanup function early
}
