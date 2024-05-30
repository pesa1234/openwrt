#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20240530
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware-r.next
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-05-30
PKG_SOURCE_VERSION:=41514f398e534af98ee8366b7612588cbad81b68
PKG_MIRROR_HASH:=3453490c984ea5d4e21d8fb5a7457e9285bccd5bef4f068df5e24701c47ea263

PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

SCAN_DEPS = *.mk

include $(INCLUDE_DIR)/package.mk

RSTRIP:=:
STRIP:=:

define Package/firmware-default
  SECTION:=firmware
  CATEGORY:=Firmware
  URL:=https://github.com/pesa1234/linux-firmware-r.next.git
  TITLE:=$(1)
  DEPENDS:=$(2)
  LICENSE_FILES:=$(3)
  LICENSE:=$(4)
endef

define Build/Compile

endef

include $(wildcard ./*.mk)
#$(eval $(call BuildPackage,linux-firmware))
