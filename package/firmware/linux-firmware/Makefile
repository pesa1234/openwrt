#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20250314
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-03-14
PKG_SOURCE_VERSION:=f4690cc580ab88b714179b7634392dcef70b8f71
PKG_MIRROR_HASH:=1eb3b92ba287e88939b8ffe5f907ab111a347bb83f570bdfdd60942661793a2e

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
