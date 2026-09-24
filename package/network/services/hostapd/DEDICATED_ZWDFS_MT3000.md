# Experimental GL-MT3000 dedicated zero-wait DFS

MT7981 uses the 5 GHz receiver's third RX path and firmware RDD2 for
background CAC. The MT6000 implementation uses a different MT7986
TX80/RX160 path; see `ADJACENT_ZWDFS_MT6000.md`.

Enable **Zero-wait DFS** on the 5 GHz radio in LuCI, or set
`wireless.radio1.zero_wait_dfs=1` in UCI. MT7981 advertises background radar
when EEPROM reports at least three 5 GHz RX paths; no `mt7915e` module
parameter or board-name match is needed. For a supported fixed channel and
width, the Wi-Fi generator writes `enable_adjacent_zwdfs=1` and
`enable_background_radar=0` to hostapd. The shared hostapd name refers to
the adjacent DFS *channel block*, not the MT7986 RF implementation.

For HE80, request channel 52, 56, 60, or 64. The AP starts on 36/80,
checks the requested 80 MHz DFS block in the background, and moves to
the requested primary by CSA when CAC succeeds. Channel 36 checks 52 by
default. For HE160 with a requested primary in 36-64, the AP starts on
36/80, checks 52-64, then expands to 160 MHz with the requested primary.
Other widths, channel lists, and DFS blocks use ordinary DFS. The
configured DFS primary is never used before CAC completes; NOP is not
bypassed. In ETSI, the off-channel check of 52-64 uses the six-minute
kernel timer shared with MT6000.

The MT7981 sequence is based on the public `mt_wifi` source archive
`mt79xx_20250408-705eb4.tar.xz` (SHA-256
`b029d7b43c498193092dc6a3c857361c8835ce34bb306561c550ac0539784a78`).
It enables `DFS_MT7981_DEDICATED_ZW`, sends `OFF_CH_SCAN_CTRL` before
starting RDD2, and configures RX path mask `0x7`. mt76 already has the
firmware command and RDD2 event routing. This branch adds the EEPROM
capability check and configures the third RX path for the dedicated receiver.

After flashing a debug router, check:

```sh
uci get wireless.radio1.zero_wait_dfs
grep -E '^(channel|enable_background_radar|enable_adjacent_zwdfs|adjacent_zwdfs_channel|adjacent_zwdfs_width|vht_oper_chwidth)=' /var/run/hostapd-phy1.conf
iw dev phy1-ap0 info
logread | grep -E 'Adjacent ZWDFS|DFS-CAC|AP-CSA|DFS-RADAR' | tail -40
```

Expect UCI value `1`, `enable_adjacent_zwdfs=1`,
`enable_background_radar=0`, and an initial `channel=36`.
In ETSI, the CAC log should show 360 seconds for the 52-64 block.
Use a wired or 2.4 GHz management connection plus an independent 5 GHz
client and beacon observer; measure association, beacons, and ping for
the entire CAC and CSA. Start with an AP-only configuration, without a
5 GHz repeater/uplink on the same radio. Test radar and NOP behavior
only after AP continuity is established.

The new MT7981 path has not been flashed or tested on a GL-MT3000.
An [mt76 issue](https://github.com/openwrt/mt76/issues/958) reports
authentication failures with generic background radar on another
MT7981 setup. The EEPROM third-RX-path check needs hardware
verification; a completed synthetic `radar_trigger` proves event
routing, not physical radar sensitivity. This is not regulatory
certification or a guarantee of uninterrupted service.
