#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20250125
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware_2024-11.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-01-25
PKG_SOURCE_VERSION:=ad580b0b3b3363932f487a9027c2372c8d5f68df
PKG_MIRROR_HASH:=0b8eaee133e3f54cabcbda552f3ae4758170b181afb5620fa6d69a85129980ca

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

SCAN_DEPS = *.mk

include $(INCLUDE_DIR)/package.mk

RSTRIP:=:
STRIP:=:

define Package/firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/pesa1234/linux-firmware_2024-11.git
  TITLE:=$(1)
  DEPENDS:=$(2)
  LICENSE_FILES:=$(3)
  LICENSE:=$(4)
endef

define Build/Compile

endef

include $(wildcard ./*.mk)
#$(eval $(call BuildPackage,linux-firmware))
