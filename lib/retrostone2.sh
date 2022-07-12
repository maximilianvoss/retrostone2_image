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

	mkdir -p "${tmp_dir}/${libsdl2_dir}"/

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

	pushd "${SRC}"/cache/sources/libsdl2
	process_patch_file "${SRC}/patch/misc/retrostone2-sdl2.patch" "applying"
	./configure --prefix="${tmp_dir}/${libsdl2_dir}"/usr
	make
	make install
  popd

	fakeroot dpkg-deb -b -Z${DEB_COMPRESS} "${tmp_dir}/${libsdl2_dir}" >/dev/null
	rsync --remove-source-files -rq "${tmp_dir}/${libsdl2_dir}.deb" "${DEB_STORAGE}/"
	rm -rf "${tmp_dir}"
}