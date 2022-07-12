#!/bin/bash

compile_sdl2()
{

	local tmp_dir libsdl2_dir
	tmp_dir=$(mktemp -d)
	chmod 700 ${tmp_dir}
	trap "ret=\$?; rm -rf \"${tmp_dir}\" ; exit \$ret" 0 1 2 3 15
	libsdl2_dir=libsdl2_${REVISION}_all
	display_alert "Building deb" "libsdl2" "info"

	fetch_from_repo "$GITHUB_SOURCE/libsdl-org/SDL" "libsdl2" "branch:main"

	mkdir -p "${tmp_dir}/${libsdl2_dir}"/{DEBIAN,usr/bin/,usr/sbin/}

	# set up control file
	cat <<-END > "${tmp_dir}/${libsdl2_dir}"/DEBIAN/control
	Package: libsdl2
	Version: 2.0.22-retrostone2
	Architecture: all
	Maintainer: $MAINTAINER <$MAINTAINERMAIL>
	Replaces:
	Depends:
	Recommends:
	Suggests:
	Section: libs
	Priority: optional
	Description: LibSDL
	END
#
#	cd "${tmp_dir}/${libsdl2_dir}"/usr/bin/

	pushd "${SRC}"/cache/sources/libsdl2
	process_patch_file "${SRC}/patch/misc/retrostone2-sdl2.patch" "applying"
	./configure --prefix="${tmp_dir}/${libsdl2_dir}"/usr/bin/
	make
	make install
  popd

#
#		# Source code checkout
#  	(fetch_from_repo "$GITHUB_SOURCE/Xilinx/bootgen.git" "xilinx-bootgen" "branch:master")
#
#  	pushd "${SRC}"/cache/sources/xilinx-bootgen || exit
#
#  	# Compile and install only if git commit hash changed
#  	# need to check if /usr/local/bin/bootgen to detect new Docker containers with old cached sources
#  	if [[ ! -f .commit_id || $(improved_git rev-parse @ 2>/dev/null) != $(<.commit_id) || ! -f /usr/local/bin/bootgen ]]; then
#  		display_alert "Compiling" "xilinx-bootgen" "info"
#  		make -s clean >/dev/null
#  		make -s -j$(nproc) bootgen >/dev/null
#  		mkdir -p /usr/local/bin/
#  		install bootgen /usr/local/bin >/dev/null 2>&1
#  		improved_git rev-parse @ 2>/dev/null > .commit_id
#  	fi
#
#  	popd


	# fallback to replace armbian-config in BSP
#	ln -sf /usr/sbin/armbian-config "${tmp_dir}/${libsdl2_dir}"/usr/bin/armbian-config
#	ln -sf /usr/sbin/softy "${tmp_dir}/${libsdl2_dir}"/usr/bin/softy

	fakeroot dpkg-deb -b -Z${DEB_COMPRESS} "${tmp_dir}/${libsdl2_dir}" >/dev/null
	rsync --remove-source-files -rq "${tmp_dir}/${libsdl2_dir}.deb" "${DEB_STORAGE}/"
	rm -rf "${tmp_dir}"
}