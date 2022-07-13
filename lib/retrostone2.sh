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

	mkdir -p "${tmp_dir}/${libsdl2_dir}"/DEBIAN

	cat <<-END > "${tmp_dir}/${libsdl2_dir}"/DEBIAN/control
	Package: libsdl2
	Version: 2.0.22-retrostone2
	Architecture: all
	Maintainer: $MAINTAINER <$MAINTAINERMAIL>
	Replaces: libsdl2, libsdl2-dev
	Depends:
	Recommends:
	Suggests:
	Section: libs
	Priority: optional
	Description: LibSDL
	END

  local toolchain
  toolchain=$(find_toolchain "$KERNEL_COMPILER" "$KERNEL_USE_GCC")
  [[ -z $toolchain ]] && exit_with_error "Could not find required toolchain" "${KERNEL_COMPILER}gcc $KERNEL_USE_GCC"

  echo ToolChain: ${toolchain}
  echo Kernel Compiler: ${KERNEL_COMPILER}
  echo Kernel Use Gcc: ${KERNEL_USE_GCC}


	pushd "${SRC}"/cache/sources/libsdl2
	process_patch_file "${SRC}/patch/misc/retrostone2-sdl2.patch" "applying"
	./configure --prefix="${tmp_dir}/${libsdl2_dir}"/usr

	make CROSS_COMPILE="$CCACHE $KERNEL_COMPILER"
	make install
  popd

  pushd ${tmp_dir}
  process_patch_file "${SRC}/patch/misc/retrostone2-sdl2-config.patch" "applying"
  popd

	fakeroot dpkg-deb -b -Z${DEB_COMPRESS} "${tmp_dir}/${libsdl2_dir}" >/dev/null
	rsync --remove-source-files -rq "${tmp_dir}/${libsdl2_dir}.deb" "${DEB_STORAGE}/"
#	rm -rf "${tmp_dir}"
}

compile_romfetcher()
{
#    apt-get --yes --force-yes --allow-unauthenticated install libsdl2-ttf-dev libsdl2-image-dev libsdl2-dev libcurl4-openssl-dev libsqlite3-dev libcurl4-openssl-dev
#    mkdir /tmp/romfetcher
#    cd /tmp/romfetcher
#    (git clone https://github.com/maximilianvoss/csafestring.git && cd csafestring && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/maximilianvoss/casserts.git && cd casserts && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/maximilianvoss/clogger.git && cd clogger && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/maximilianvoss/chttp.git && cd chttp && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/maximilianvoss/acll.git && cd acll && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/lexbor/lexbor.git && cd lexbor && cmake -G "Unix Makefiles" && make && sudo make install)
#    (git clone https://github.com/maximilianvoss/romlibrary.git; cd romlibrary; cmake -G "Unix Makefiles"; make; sudo make install)
#    (git clone https://github.com/maximilianvoss/romfetcher.git; cd romfetcher; cmake -G "Unix Makefiles"; make; sudo make install)
#    cd /
#    rm -rf /tmp/romfetcher
  echo "hello world"
}