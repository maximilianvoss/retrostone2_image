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
 ```
 [   83.690550] reboot: Restarting system
```
* `shutdown` is halting but not powering off
 ```
[   90.046464] ——————[ cut here ]——————
[   90.051085] WARNING: CPU: 0 PID: 1 at drivers/i2c/i2c-core.h:41 i2c_transfer+0x93/0xbc
[   90.059020] No atomic I2C transfer handler for 'i2c-0'
[   90.064152] Modules linked in: brcmfmac brcmutil at24 cfg80211 axp20x_battery evdev joydev axp20x_adc sun4i_gpadc_iio input_leds industrialio sun4i_ts sun4i_codec sunxi_cedrus(C) v4l2_mem2mem videobuf2_dma_contig videobuf2_memops videobuf2_v4l2 videobuf2_common lz4hc lz4 uio_pdrv_genirq uio cpufreq_dt zram sch_fq_codel bonding hidp rfcomm hci_uart btrtl btbcm bluetooth ecdh_generic rfkill ecc ramoops reed_solomon pstore_blk pstore_zone ip_tables x_tables autofs4 hid_logitech_hidpp lima gpu_sched pinctrl_axp209 sun4i_gpadc pwm_sun4i sunxi phy_generic panel_simple drm_dp_aux_bus pwrseq_emmc pwrseq_simple display_connector pwm_bl hid_logitech_dj
[   90.121210] CPU: 0 PID: 1 Comm: systemd-shutdow Tainted: G         C        5.15.75-sunxi #trunk
[   90.129990] Hardware name: Allwinner sun7i (A20) Family
[   90.135219] [<c010cd21>] (unwind_backtrace) from [<c01095fd>] (show_stack+0x11/0x14)
[   90.142975] [<c01095fd>] (show_stack) from [<c09e0c4d>] (dump_stack_lvl+0x2b/0x34)
[   90.150556] [<c09e0c4d>] (dump_stack_lvl) from [<c011c3f9>] (__warn+0xad/0xc0)
[   90.157787] [<c011c3f9>] (__warn) from [<c09da8eb>] (warn_slowpath_fmt+0x5f/0x7c)
[   90.165274] [<c09da8eb>] (warn_slowpath_fmt) from [<c07a7d1f>] (i2c_transfer+0x93/0xbc)
[   90.173284] [<c07a7d1f>] (i2c_transfer) from [<c07a7d83>] (i2c_transfer_buffer_flags+0x3b/0x50)
[   90.181989] [<c07a7d83>] (i2c_transfer_buffer_flags) from [<c06a79ef>] (regmap_i2c_write+0x13/0x24)
[   90.191044] [<c06a79ef>] (regmap_i2c_write) from [<c06a449b>] (_regmap_raw_write_impl+0x48b/0x560)
[   90.200007] [<c06a449b>] (_regmap_raw_write_impl) from [<c06a45b1>] (_regmap_bus_raw_write+0x41/0x5c)
[   90.209227] [<c06a45b1>] (_regmap_bus_raw_write) from [<c06a3e29>] (_regmap_write+0x35/0xc8)
[   90.217667] [<c06a3e29>] (_regmap_write) from [<c06a4d2d>] (regmap_write+0x29/0x3c)
[   90.225327] [<c06a4d2d>] (regmap_write) from [<c06aebb3>] (axp20x_power_off+0x23/0x30)
[   90.233251] [<c06aebb3>] (axp20x_power_off) from [<c0138e7d>] (__do_sys_reboot+0xf5/0x16c)
[   90.241522] [<c0138e7d>] (__do_sys_reboot) from [<c0100061>] (ret_fast_syscall+0x1/0x52)
[   90.249606] Exception stack(0xc1559fa8 to 0xc1559ff0)
[   90.254660] 9fa0:                   00000000 00000000 fee1dead 28121969 4321fedc 4321fedc
[   90.262834] 9fc0: 00000000 00000000 00000003 00000058 becb1a84 fffff000 004967ac 00000006
[   90.271004] 9fe0: 00000058 becb19f4 b6c2d185 b6b9db06
[   90.276051] —[ end trace 953d131e9f13ec79 ]—
[   92.073887] i2c i2c-0: mv64xxx: I2C bus locked, block: 1, time_left: 0
[   92.585888] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000000
[   92.593543] CPU: 0 PID: 1 Comm: systemd-shutdow Tainted: G        WC        5.15.75-sunxi #trunk
[   92.602324] Hardware name: Allwinner sun7i (A20) Family
[   92.607549] [<c010cd21>] (unwind_backtrace) from [<c01095fd>] (show_stack+0x11/0x14)
[   92.615307] [<c01095fd>] (show_stack) from [<c09e0c4d>] (dump_stack_lvl+0x2b/0x34)
[   92.622886] [<c09e0c4d>] (dump_stack_lvl) from [<c09da715>] (panic+0xc1/0x238)
[   92.630114] [<c09da715>] (panic) from [<c0120c03>] (do_exit+0x86b/0x86c)
[   92.636821] [<c0120c03>] (do_exit) from [<c0138e83>] (__do_sys_reboot+0xfb/0x16c)
[   92.644309] [<c0138e83>] (__do_sys_reboot) from [<c0100061>] (ret_fast_syscall+0x1/0x52)
[   92.652400] Exception stack(0xc1559fa8 to 0xc1559ff0)
[   92.657453] 9fa0:                   00000000 00000000 fee1dead 28121969 4321fedc 4321fedc
[   92.665627] 9fc0: 00000000 00000000 00000003 00000058 becb1a84 fffff000 004967ac 00000006
[   92.673797] 9fe0: 00000058 becb19f4 b6c2d185 b6b9db06
[   92.678858] —[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000000 ]—
```
* Uboot booting directly NAND 

# Booting from NAND
It is possible that the main OS is loaded from the NAND flash, whereby the SD card will hold the `/boot` folder including
u-boot instructions and the kernel. 

1. Flash your SD Card with image.img
2. Boot Retrostone2
3. Do default configuration
4. Copy the image.img to the Retrostone2 
 ```bash
scp image.img root@retrostone2:~/image.img
```
5. Flash the NAND
 ```bash
dd if=/root/image.img of=/dev/mmcblk1
```
6. Reboot
7. Generate new UUID for the SD Card
 ```bash
tune2fs -U random /dev/mmcblk0p1
```
8. Reboot
9. Mount SD Card
 ```bash
mount /dev/mmcblk0p1 /mnt
```
10. Delete unnecessary clutter
 ```bash
cd /mnt
ls | grep -v boot | grep -v lost+found | xargs rm -rf
```
11. Reboot
12. Done