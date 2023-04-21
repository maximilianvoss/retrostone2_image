#!/bin/bash

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



./compile.sh \
BOARD=retrostone2 \
BRANCH=current \
RELEASE=jammy \
BUILD_DESKTOP=yes \
DESKTOP_ENVIRONMENT=retrostone2 \
KERNEL_CONFIGURE=no \
DESKTOP_ENVIRONMENT_CONFIG_NAME=config_base \
DESKTOP_APPGROUPS_SELECTED=y \
EXTERNAL_NEW=compile \
KERNEL_GIT=shallow \
ARTIFACT_IGNORE_CACHE=yes