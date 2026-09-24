> Superseded: see [source-backed findings](ADJACENT_CAC_SOURCE_FINDINGS.md). The source was found after this initial report.

# MT7981/MT7986 adjacent CAC: investigation status

This is an experimental probe, **not validated zero-wait DFS**. Do not enable
`adjacent_cac` on a router whose 5 GHz connection must remain available.

## What the current prototype proves

With an MT6000 AP on channel 36/80 MHz and background CAC requested on
channels 52–64/80 MHz, `iw` and hostapd report CAC start/completion. A
synthetic `radar_trigger` during CAC produces a background radar event on
5260 MHz. This tests the event-routing path, not physical radar sensitivity.

It does **not** prove simultaneous AP transmission and DFS monitoring. In the
observed test, the client was removed about 5.6 seconds after CAC started and
rejoined only after CAC finished (or after the simulated radar stopped it).
The AP still appeared on channel 36 in `iw dev`, but connectivity was lost.

## Evidence from MediaTek's published mt76 patches

- `1048-wifi-mt76-mt7915-add-background-radar-hw-cap-check.patch` implements
  `mt7915_eeprom_has_background_radar()` and returns false for chip IDs
  `0x7981` and `0x7986`.
- `1056-wifi-mt76-mt7915-rework-radar-rdd-idx.patch` lists the background
  HWRDD index as N/A for MT7981 and for all listed MT7986 variants. This
  rules out treating the main RDD as an independent background chain in mt76.
- `1049-wifi-mt76-mt7915-add-foolproof-mechanism-for-ZWDFS-d.patch` only
  safeguards the dedicated background-RDD path; it does not implement the
  proprietary adjacent TX80/RX160 state machine.

These patches are in the sibling `private/mtk-openwrt-feeds` checkout under
`autobuild/autobuild_5.4_mac80211_release/package/kernel/mt76/patches/`.
They do **not** establish that proprietary adjacent TX80/RX160 is impossible.

## Proprietary-driver observations versus our MCU requests

Boot logs copied to the [OpenWrt XDR-6086 page](https://openwrt.org/toh/tp-link/xdr-6086)
show `DFS_BW160_TX80RX160`, `IS_ADJ_BW_ZERO_WAIT_TX80RX160=1`, an explicit
`Enable MAC TX`, and channel-switch/RX-path logs with `ucBW=3`, `ucAPBW=3`,
center channel 50. The log predicate may be driver-internal; it is not known
to be a firmware command field.

Our `9999-29`/`9999-30` patches send `CHANNEL_SWITCH` and `SET_RX_PATH` with
`bw=160`, `ap_bw=80`, center channel 50, and AP center channel 42. They start
the **main** RDD and call `MURU_SET_SUTX`. They neither reproduce the observed
`ucAPBW=3` request nor implement/verify the proprietary state transition or
the explicit MAC-TX enable step. The difference is evidence of an incomplete
port, **not** a proven explanation for the connectivity loss.

The `9999-cfg80211-notify-background-cac-abort-after-radar.patch` change in
mac80211 fixes missing userspace notification of CAC abort after radar. It is
independent of the RF continuity problem.

## Information needed before another active experiment

1. Obtain a usable `mt_wifi` source tree or passive traces from an OEM device
   running the adjacent TX80/RX160 mode. The local MediaTek feed contains
   mt76 patches, not that proprietary implementation.
2. Identify the exact MCU payloads and order for `CHANNEL_SWITCH`,
   `SET_RX_PATH`, RDD control, and MAC TX control, including `cac_case`,
   `outband_freq`, `switch_reason`, `ap_bw`, and `ap_center_ch`.
3. Determine how the proprietary driver keeps beacon/data TX at 80 MHz while
   receiving 160 MHz and which firmware/hardware versions support this.
4. Only then test on a debug router managed over Ethernet or 2.4 GHz, with an
   independent 5 GHz client and beacon observer. Require continuous beacon,
   association, and ping during the entire CAC; then verify the radar/NOP
   path. `radar_trigger` alone cannot validate real radar detection.

Until these conditions are met, keep the UI label as *background radar* and
the `adjacent_cac` module parameter off for normal use. In particular, do not
interpret a completed synthetic CAC as certification that a DFS channel is
safe to use.
