#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20250925
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-09-25
PKG_SOURCE_VERSION:=0752bf7dbc924b7f4d764c83365adc2fb5e5051f
PKG_MIRROR_HASH:=a4c901d0e9a32e92168b0b1378c581905044834e8848534291ddb799f2d0505e

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

SCAN_DEPS = *.mk

include $(INCLUDE_DIR)/package.mk

RSTRIP:=:
STRIP:=:

define Package/firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/pesa1234/linux-firmware.git
  TITLE:=$(1)
  DEPENDS:=$(2)
  LICENSE_FILES:=$(3)
  LICENSE:=$(4)
endef

define Build/Compile

endef

include $(wildcard ./*.mk)
#$(eval $(call BuildPackage,linux-firmware))
