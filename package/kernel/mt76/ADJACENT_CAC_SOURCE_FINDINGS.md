# MT7986 adjacent DFS: source-backed findings

Status: experimental, not validated zero-wait DFS. The earlier
`ADJACENT_CAC_RESEARCH.md` was written before the driver source was found.

## Source examined

The public [mt_wifi package recipe](https://github.com/chasey-dev/immortalwrt-mt798x-rebase/blob/25.12/package/mtk/drivers/mt_wifi/Makefile)
references [mt79xx_20250408-705eb4.tar.xz](https://raw.githubusercontent.com/hanwckf/immortalwrt-mt798x/refs/heads/openwrt-21.02/dl/mt79xx_20250408-705eb4.tar.xz).
The archive's SHA-256 is
`b029d7b43c498193092dc6a3c857361c8835ce34bb306561c550ac0539784a78`,
matching the package recipe. Its `mt_wifi/os/linux/Makefile.mt_wifi_ap`
enables `DFS_ADJ_BW_ZERO_WAIT` for MT7986. MT7981 has a different
`DFS_MT7981_DEDICATED_ZW` build path; do not generalize MT6000 results to
MT3000.

The source was reviewed in `/tmp/mtwifi-review-2026-09-23-705eb4/mt_wifi`
without importing it into the SmartWRT build.

## Actual MT7986 sequence

1. `embedded/common/cmm_rdm_mt.c`: adjacent state records the out-band
   channel and keeps the live AP's advertised width at 80 MHz.
2. `mcu/mt_cmd.c`: when that *driver-side state* is active,
   `MtCmdChannelSwitch` and `MtCmdSetTxRxPath` send firmware BW=160,
   APBW=160, center channel 50. `IS_ADJ_BW_ZERO_WAIT_TX80RX160` is a C
   predicate, **not** an identified firmware flag.
3. `DfsCacNormalStart` sends `NORMAL_START` to the main RDD, explicitly
   keeping MAC TX enabled. `DfsRadarDetectStart` sends `RDD_START` for
   radar detection. The adjacent path does not send `CAC_START`.
4. After CAC, `DfsCacEndUpdate` handles the saved out-band channel,
   bandwidth transition, SU-mode restoration, and channel-switch work.

Our previous prototype sent APBW=80 and `RDD_CAC_START`. The latter is the
normal, TX-silencing CAC command and plausibly explains the client outage.
The consolidated `9999-29-wifi-mt76-mt7915-experimental-adjacent-cac.patch`
sends `RDD_NORMAL_START` before the channel/RX-path change, uses BW=APBW=160,
then starts radar detection without `RDD_CAC_START`. The source-backed change
compiled locally; it has **not** been flashed or tested on the router.

## Remaining proof required

- A firmware ACK and `CAC started` event do not prove that radar is monitored
  over the entire DFS half of the 160 MHz receive channel.
- `radar_trigger` proves event routing only, not RF detection sensitivity.
- An active-AP channel reconfiguration may still briefly interrupt beaconing
  even with `RDD_NORMAL_START`; the proprietary driver also manages AP/STA
  state, SU mode, and the CAC-end channel transition.
- `cfg80211` may mark the DFS target *available* after a completed background
  CAC. Do not use that result for DFS operation until the RF behavior is
  independently validated.

Next test, if chosen: manage the debug router over Ethernet or 2.4 GHz, use
an independent 5 GHz client plus beacon observer, and measure ping, station
association, and beacon continuity through the full background CAC. Only
after continuity is demonstrated should radar/NOP handling be investigated.
Do not rename the UI control to "Zero-wait DFS" yet.
