# Retrostone2
I bought the Retrostone2 Pro years ago in the good faith the software will improve over time. Unfortunately time showed 
that there is no update of RetrOrangePi since 2019 and there is no update to be expected in the very near future.
After time I came to the conclusion that the only way to improve the Software for my Retrostone2 - which is indeed
a very nice gadget - is to create my own image.

This image is completely based on the latest Armbian. All files I created a prefixed with `retrostone2-` and I intended
to only change as minimal as possible on the existing Armbian distribution to always have a path forward.

## Things I introduced on the Armbian distribution
* [/customzation](customization): this folder holds all files to customize the image after build. It overwrites whatever there is on customization in `userpatches`
* [/retrostone2-patches](retrostone2-patches): it contains the original files and the adaptations which are needed for the Retrostone2. It helps in updating to newer versions of u-boot and kernel

## Building your own image
### What you need to have installed on your latest Ubuntu (22.04.1 LTS)
```bash
apt-get install ntpdate jq aria2 pv binfmt-support ccache gcc-11 aptly bison build-essential debian-archive-keyring debian-keyring device-tree-compiler dwarves flex gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu libbison-dev libc6-dev-armhf-cross libcrypto++-dev libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev liblz4-tool libncurses-dev libpython2.7-dev libssl-dev libusb-1.0-0-dev patchutils pixz pkg-config python3-distutils qemu-user-static swig u-boot-tools uuid-dev zlib1g-dev lib32ncurses-dev lib32stdc++6 libc6-i386 python2 apt-cacher-ng
```

### Command to execute build
```bash
 ./compile.sh \
 BOARD=retrostone2 \
 USE_GITHUB_UBOOT_MIRROR=yes \
 KERNEL_ONLY=no \
 KERNEL_CONFIGURE=no \
 RELEASE=jammy \
 BUILD_DESKTOP=yes \
 DESKTOP_ENVIRONMENT=retrostone2 \
 DISABLE_IPV6=true \
 MAINLINE_MIRROR=google \
 CLEAN_LEVEL=images \
 NO_APT_CACHER=yes \
 EXTERNAL_NEW=compile \
 DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base \
 DESKTOP_APPGROUPS_SELECTED=y \
 RELEASE=jammy \
 ARCH=armhf \
 EXTRAWIFI=no
```

## Known Issues
* `reboot` is actually shutting down the device
* `shutdown` is halting but not powering off
* No booting from NAND
