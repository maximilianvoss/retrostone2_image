# Build for Retrostone2

## 2 Do
[ ] armbian-firstrun - enables Mali out-of-the-tree module and Bluetooth service : /usr/lib/armbian  
[ ] btpatch.tar.gz - Broadcom utility to flash Bluetooth firmwares - must be extracted to /  
[ ] e.py - Python script for controller buttons testing  
[ ] GuiMenu.cpp - EmulationStation GUI menu source file  
[ ] GuiMenu.h - EmulationStation GUI menu header  
[ ] gpio_retrostone2-production-with-brightness.py - Enables the Retrostone GPIO controls - /home/pi/RetrOrangePi/GPIO/drivers/tz_gpio_controller.py  
[ ] joystick.rules - UDEV rule to give write privileges to input : /etc/udev/rules.d/ (not tested yet)  
[X] kernel-sunxi-current.patch - Armbian kernel patch (v5.3.13) -> retrostone2-kernel.patch   
[ ] retroarch.cfg - Retroarch configuration file: /opt/retropie/configs/all/  
[ ] RetroStone2 Controle.cfg - Controller configuration file: /opt/retropie/configs/all/retroarch/autoconfig/
[X] retrostone2.csc - Armbian Retrostone 2 configuration - adds board to Armbian building script: build/config/boards   
[ ] ropi-rs2-final.sh - simple test script (network, bluetooth, storage, audio and controls)  
[ ] RS2GPIO.tar.gz - GPIO sources - /home/pi/RetrOrangePi/GPIO/  
[ ] SDL_gamecontrollerdb.h - add support to Retrostone controller in SDL2 sources  
[?] sun7i-a20-retrostone2.dts - adds Retrostone DTS with backlight/LCD support -> already included in retrostone2-u-boot.patch  
[X] u-boot-sunxi-current.patch - Armbian u-boot patch -> retrostone2-u-boot.patch  

```bash
apt-get install ntpdate jq aria2 pv binfmt-support ccache gcc-11 aptly bison build-essential debian-archive-keyring debian-keyring device-tree-compiler dwarves flex gcc-arm-linux-gnueabi gcc-aarch64-linux-gnu libbison-dev libc6-dev-armhf-cross libcrypto++-dev libelf-dev libfdt-dev libfile-fcntllock-perl libfl-dev liblz4-tool libncurses-dev libpython2.7-dev libssl-dev libusb-1.0-0-dev patchutils pixz pkg-config python3-distutils qemu-user-static swig u-boot-tools uuid-dev zlib1g-dev lib32ncurses-dev lib32stdc++6 libc6-i386 python2 apt-cacher-ng
```


```bash
 ./compile.sh \
 BOARD=retrostone2 \
 USE_GITHUB_UBOOT_MIRROR=yes \
 KERNEL_ONLY=no \
 KERNEL_CONFIGURE=no \
 RELEASE=jammy \
 BUILD_DESKTOP=yes \
 DESKTOP_ENVIRONMENT=emulationstation \
 DISABLE_IPV6=true \
 MAINLINE_MIRROR=google \
 CLEAN_LEVEL=images \
 NO_APT_CACHER=yes \
 EXTERNAL_NEW=compile \
 DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base \
 DESKTOP_APPGROUPS_SELECTED=y \
 CARD_DEVICE="/dev/sdb"
```


