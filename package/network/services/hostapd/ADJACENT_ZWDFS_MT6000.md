# Experimental MT6000 adjacent zero-wait DFS

This implementation is opt-in and restricted to GL-MT6000 with
`mt7915e adjacent_cac=Y`. It reuses the LuCI **background radar** checkbox
(`wireless.radio1.background_radar=1`). On this board, the generated hostapd
configuration uses `enable_adjacent_zwdfs=1` and
`enable_background_radar=0`; other devices retain the generic background-radar
setting. Leave the UI wording unchanged while this is experimental.

With the 5 GHz AP configured for HE80 and legal DFS-ETSI operation, choose
channel 52, 56, 60, or 64 in UCI. The generator remembers that primary as
`adjacent_zwdfs_channel` while hostapd starts temporarily on 36/80. It runs
background CAC on the chosen 80 MHz DFS block, then moves to the selected
primary by CSA after CAC succeeds. Channel 36 retains the original prototype
default of checking 52. Radar during background CAC aborts the check without
moving the AP. Radar on the operating DFS channel makes hostapd select only
available channels for its first CSA attempt. If none exist, the ordinary
hostapd fallback can still incur CAC or disable/restart the AP; this is not a
guarantee of uninterrupted service. NOP is never bypassed.

For `HE160` (or `VHT160`) with a requested primary in 36, 40, 44, 48,
52, 56, 60, or 64, the AP starts on 36/80 and checks the 52-64 block.
After a successful background CAC it uses CSA to operate at 160 MHz,
center channel 50, with the requested primary. Radar on the operating
160 MHz channel returns the AP to 36/80; after NOP expiry it can run a
fresh adjacent CAC and expand again. The 100-128/160 block is not
adjacent to a non-DFS 80 MHz block and uses ordinary DFS, not this path.

On a debug router after flashing, verify before injecting radar:

```
cat /sys/module/mt7915e/parameters/adjacent_cac
grep -E '^(channel|enable_background_radar|enable_adjacent_zwdfs|adjacent_zwdfs_channel|adjacent_zwdfs_width|vht_oper_chwidth)=' /var/run/hostapd-phy1.conf
iw dev phy1-ap0 info
logread | grep -E 'Adjacent ZWDFS|DFS-CAC|AP-CSA|DFS-RADAR' | tail -40
```

Expected: module parameter `Y`, `enable_adjacent_zwdfs=1`,
`enable_background_radar=0`, `channel=36`, and
`adjacent_zwdfs_channel=<requested primary>`. For HE80, background CAC uses
the requested DFS primary; for HE160 with a lower-block primary it checks
channel 52 instead. In both cases the checked 80 MHz block is centered on
5290 MHz while the AP stays on 36, then follows a CSA. Observe an independent
ping and `iw event -t` throughout.
For the 160 MHz path, also expect `adjacent_zwdfs_width=160`, an initial
`vht_oper_chwidth=1`, `DFS-CAC-START ... cac_time=360s (background)` in
IT/ETSI, and final `iw` width 160 MHz. A synthetic on-channel radar test
belongs only on the debug unit. NOP applies to the affected DFS block.
Automatic re-expansion after NOP is available only after the 160 MHz radar
fallback to 36/80; the 80 MHz path on another fallback channel does not
automatically return to the original DFS channel.

Do not treat `radar_trigger` as a physical radar sensitivity test. Regulatory
conformance, including ETSI uniform spreading, detection thresholds, and
real RF detection, remains unvalidated. The six-minute kernel timer only
addresses the minimum off-channel CAC duration; it is not certification.
Do not rely on days without a real radar event as proof of compliance. The
MT7981/MT3000 uses a different MediaTek zero-wait path and is intentionally
not covered here.
