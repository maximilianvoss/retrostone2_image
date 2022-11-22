#!/bin/bash

# armbian-firstlogin
patchfile=../customization/overlay/retrostone2-armbian-firstlogin.patch
cat <<-EOF > $patchfile
--- usr/lib/armbian/armbian-firstlogin
+++ usr/lib/armbian/armbian-firstlogin
EOF
diff -Naur ../packages/bsp/common/usr/lib/armbian/armbian-firstlogin ./armbian/armbian-firstlogin | tail -n +3 >>$patchfile

# SDL2 Patch
patchfile=../packages/extras-buildpkgs/libsdl2-2.0-0/debian/patches/retrostone2-sdl2.patch
cat <<-EOF > $patchfile
diff --git a/src/joystick/SDL_gamecontrollerdb.h b/src/joystick/SDL_gamecontrollerdb.h
index aa9d35780..2698d5632 100644
--- a/src/joystick/SDL_gamecontrollerdb.h
+++ b/src/joystick/SDL_gamecontrollerdb.h
EOF
curl -o SDL_gamecontrollerdb.h https://raw.githubusercontent.com/libsdl-org/SDL/release-2.0.22/src/joystick/SDL_gamecontrollerdb.h
diff -Naur SDL_gamecontrollerdb.h SDL/SDL_gamecontrollerdb.h | tail -n +3 >>$patchfile
rm SDL_gamecontrollerdb.h

# Kernel Patch
patchfile=../patch/kernel/sunxi-current/retrostone2-kernel.patch
cat <<-EOF >$patchfile
diff --git a/arch/arm/boot/dts/Makefile b/arch/arm/boot/dts/Makefile
index 9f4bc9e02..2ceacb164 100644
--- a/arch/arm/boot/dts/Makefile
+++ b/arch/arm/boot/dts/Makefile
EOF
diff -Naur kernel/original/Makefile kernel/retrostone2/Makefile | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/arch/arm/boot/dts/sun7i-a20-retrostone2.dts b/arch/arm/boot/dts/sun7i-a20-retrostone2.dts
new file mode 100644
index 000000000..547381d62
--- /dev/null
+++ b/arch/arm/boot/dts/sun7i-a20-retrostone2.dts
EOF
diff -Naur kernel/original/sun7i-a20-retrostone2.dts kernel/retrostone2/sun7i-a20-retrostone2.dts | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/arch/arm/boot/dts/sun7i-a20.dtsi b/arch/arm/boot/dts/sun7i-a20.dtsi
index 9ad8e445b..9b0b830f5 100644
--- a/arch/arm/boot/dts/sun7i-a20.dtsi
+++ b/arch/arm/boot/dts/sun7i-a20.dtsi
EOF
diff -Naur kernel/original/sun7i-a20.dtsi kernel/retrostone2/sun7i-a20.dtsi | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/drivers/i2c/busses/i2c-mv64xxx.c b/drivers/i2c/busses/i2c-mv64xxx.c
index ee6900eb3..8b8d81e8e 100644
--- a/drivers/i2c/busses/i2c-mv64xxx.c
+++ b/drivers/i2c/busses/i2c-mv64xxx.c
EOF
diff -Naur kernel/original/i2c-mv64xxx.c kernel/retrostone2/i2c-mv64xxx.c | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/drivers/gpu/drm/panel/panel-simple.c b/drivers/gpu/drm/panel/panel-simple.c
index ee6900eb3..8b8d81e8e 100644
--- a/drivers/gpu/drm/panel/panel-simple.c
+++ b/drivers/gpu/drm/panel/panel-simple.c
EOF
diff -Naur kernel/original/panel-simple.c kernel/retrostone2/panel-simple.c | tail -n +3 >>$patchfile

# U-Boot
patchfile=../patch/u-boot/u-boot-sunxi/board_retrostone2/retrostone2-u-boot.patch
cat <<-EOF >$patchfile
diff --git a/arch/arm/dts/Makefile b/arch/arm/dts/Makefile
index 94e01f3..0415451 100755
--- a/arch/arm/dts/Makefile
+++ b/arch/arm/dts/Makefile
EOF
diff -Naur u-boot/original/Makefile u-boot/retrostone2/Makefile | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/arch/arm/dts/sun7i-a20-retrostone2.dts b/arch/arm/dts/sun7i-a20-retrostone2.dts
new file mode 100644
index 0000000..1739982
--- /dev/null
+++ b/arch/arm/dts/sun7i-a20-retrostone2.dts
EOF
diff -Naur u-boot/original/sun7i-a20-retrostone2.dts u-boot/retrostone2/sun7i-a20-retrostone2.dts | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/arch/arm/dts/sun7i-a20.dtsi b/arch/arm/dts/sun7i-a20.dtsi
index e529e4f..2e47789 100644
--- a/arch/arm/dts/sun7i-a20.dtsi
+++ b/arch/arm/dts/sun7i-a20.dtsi
EOF
diff -Naur u-boot/original/sun7i-a20.dtsi u-boot/retrostone2/sun7i-a20.dtsi | tail -n +3 >>$patchfile

cat <<-EOF >>$patchfile
diff --git a/configs/A20-Retrostone2_defconfig b/configs/A20-Retrostone2_defconfig
new file mode 100644
index 0000000..4302b2c
--- /dev/null
+++ b/configs/A20-Retrostone2_defconfig
EOF
diff -Naur u-boot/original/A20-Retrostone2_defconfig u-boot/retrostone2/A20-Retrostone2_defconfig | tail -n +3 >>$patchfile
