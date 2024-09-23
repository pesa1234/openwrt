#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20240923
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware-09-24
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-09-23
PKG_SOURCE_VERSION:=64ad4fcfee547117879c43eef7d957ea2c2cffb5
PKG_MIRROR_HASH:=11802a2f7bb5423735484e93f52f6ab462324df2765ec82bb5060d7eb30d8778

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

SCAN_DEPS = *.mk

include $(INCLUDE_DIR)/package.mk

RSTRIP:=:
STRIP:=:

define Package/firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/pesa1234/linux-firmware-09-24.git
  TITLE:=$(1)
  DEPENDS:=$(2)
  LICENSE_FILES:=$(3)
  LICENSE:=$(4)
endef

define Build/Compile

endef

include $(wildcard ./*.mk)
#$(eval $(call BuildPackage,linux-firmware))
