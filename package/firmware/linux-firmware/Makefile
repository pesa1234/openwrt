#
# Copyright (C) 2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=linux-firmware
PKG_VERSION:=20240825
PKG_RELEASE:=1.1

PKG_SOURCE_URL:=https://github.com/pesa1234/linux-firmware-r.next
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2024-08-25
PKG_SOURCE_VERSION:=f02cce135268a1741b610e9c243f8d0b53e9f4e2
PKG_MIRROR_HASH:=5d91238db9ac6a16e4df28771353c7da81a0d957fe1fc88f1ede86dcdfecc911

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
