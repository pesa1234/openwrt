# Copyright (C) 2021 OpenWrt.org
#

. /lib/functions.sh

emmc_upgrade_tar() {
	local tar_file="$1"
	[ "$CI_KERNPART" -a -z "$EMMC_KERN_DEV" ] && export EMMC_KERN_DEV="$(find_mmc_part $CI_KERNPART $CI_ROOTDEV)"
	[ "$CI_ROOTPART" -a -z "$EMMC_ROOT_DEV" ] && export EMMC_ROOT_DEV="$(find_mmc_part $CI_ROOTPART $CI_ROOTDEV)"
	[ "$CI_DATAPART" -a -z "$EMMC_DATA_DEV" ] && export EMMC_DATA_DEV="$(find_mmc_part $CI_DATAPART $CI_ROOTDEV)"
	[ "$CI_DTBPART" -a -z "$EMMC_DTB_DEV" ]   && export EMMC_DTB_DEV="$(find_mmc_part $CI_DTBPART $CI_ROOTDEV)"
	local has_kernel
	local has_rootfs
	local has_dtb
	local gz
	local board_dir
	[ "$(identify_magic_long $(get_magic_long "$tar_file" cat))" = "gzip" ] && \
		gz="z"
	board_dir=$(tar t${gz}f "$tar_file" | grep -m 1 '^sysupgrade-.*/$')
	board_dir=${board_dir%/}

	tar t${gz}f "$tar_file" ${board_dir}/kernel 1>/dev/null 2>/dev/null && has_kernel=1
	tar t${gz}f "$tar_file" ${board_dir}/root 1>/dev/null 2>/dev/null && has_rootfs=1
	tar t${gz}f "$tar_file" ${board_dir}/dtb 1>/dev/null 2>/dev/null && has_dtb=1

	[ "$has_rootfs" = 1 -a "$EMMC_ROOT_DEV" ] && {
		# Invalidate kernel image while rootfs is being written
		[ "$has_kernel" = 1 -a "$EMMC_KERN_DEV" ] && {
			dd if=/dev/zero of="$EMMC_KERN_DEV" bs=512 count=8
			sync
		}

		export EMMC_ROOTFS_BLOCKS=$(($(tar x${gz}f "$tar_file" ${board_dir}/root -O | dd of="$EMMC_ROOT_DEV" bs=512 2>&1 | grep "records out" | cut -d' ' -f1)))
		# Account for 64KiB ROOTDEV_OVERLAY_ALIGN in libfstools
		EMMC_ROOTFS_BLOCKS=$(((EMMC_ROOTFS_BLOCKS + 127) & ~127))
		sync
	}
	[ "$has_dtb" = 1 -a "$EMMC_DTB_DEV" ] &&
		export EMMC_DTB_BLOCKS=$(($(tar x${gz}f "$tar_file" ${board_dir}/dtb -O | dd of="$EMMC_DTB_DEV" bs=512 2>&1 | grep "records out" | cut -d' ' -f1)))

	[ "$has_kernel" = 1 -a "$EMMC_KERN_DEV" ] &&
		export EMMC_KERNEL_BLOCKS=$(($(tar x${gz}f "$tar_file" ${board_dir}/kernel -O | dd of="$EMMC_KERN_DEV" bs=512 2>&1 | grep "records out" | cut -d' ' -f1)))

	if [ -z "$UPGRADE_BACKUP" ]; then
		if [ "$EMMC_DATA_DEV" ]; then
			dd if=/dev/zero of="$EMMC_DATA_DEV" bs=512 count=8
		elif [ "$EMMC_ROOTFS_BLOCKS" ]; then
			dd if=/dev/zero of="$EMMC_ROOT_DEV" bs=512 seek=$EMMC_ROOTFS_BLOCKS count=8
		elif [ "$EMMC_KERNEL_BLOCKS" ]; then
			dd if=/dev/zero of="$EMMC_KERN_DEV" bs=512 seek=$EMMC_KERNEL_BLOCKS count=8
		fi
	fi
}

emmc_upgrade_fit() {
	local fit_file="$1"
	[ "$CI_KERNPART" -a -z "$EMMC_KERN_DEV" ] && export EMMC_KERN_DEV="$(find_mmc_part $CI_KERNPART $CI_ROOTDEV)"

	if [ "$EMMC_KERN_DEV" ]; then
		export EMMC_KERNEL_BLOCKS=$(($(get_image "$fit_file" | fwtool -i /dev/null -T - | dd of="$EMMC_KERN_DEV" bs=512 2>&1 | grep "records out" | cut -d' ' -f1)))

		[ -z "$UPGRADE_BACKUP" ] && dd if=/dev/zero of="$EMMC_KERN_DEV" bs=512 seek=$EMMC_KERNEL_BLOCKS count=8
	fi
}

emmc_copy_config() {
	if [ "$EMMC_DATA_DEV" ]; then
		dd if="$UPGRADE_BACKUP" of="$EMMC_DATA_DEV" bs=512
	elif [ "$EMMC_ROOTFS_BLOCKS" ]; then
		dd if="$UPGRADE_BACKUP" of="$EMMC_ROOT_DEV" bs=512 seek=$EMMC_ROOTFS_BLOCKS
	elif [ "$EMMC_KERNEL_BLOCKS" ]; then
		dd if="$UPGRADE_BACKUP" of="$EMMC_KERN_DEV" bs=512 seek=$EMMC_KERNEL_BLOCKS
	fi
}

emmc_do_upgrade() {
	local file_type=$(identify_magic_long "$(get_magic_long "$1")")

	case "$file_type" in
		"fit")  emmc_upgrade_fit $1;;
		*)      emmc_upgrade_tar $1;;
	esac
}
