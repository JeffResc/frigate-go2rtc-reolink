# frigate-go2rtc-reolink

Frigate image with go2rtc rebuilt from an unmerged pull request that adds
native support for Reolink's proprietary Baichuan protocol
(`reolink://user:pass@ip/main?channel=0`).

## Why this exists

The [stock bridge from Reolink's Baichuan protocol to RTSP, neolink](https://github.com/QuantumEntangledAndy/neolink),
leaks a file descriptor per unique compressed frame size
([issue #422](https://github.com/QuantumEntangledAndy/neolink/issues/422)),
exhausting its 65,535 fd limit within minutes and stuttering every bridged
stream. The fork that ships that bug is effectively unmaintained (last merge
to `main`: January 2025), and the fix for it
([PR #423](https://github.com/QuantumEntangledAndy/neolink/pull/423)) sits
unreviewed.

[AlexxIT/go2rtc#2263](https://github.com/AlexxIT/go2rtc/pull/2263) adds native
Baichuan protocol support directly to go2rtc (which Frigate already bundles),
removing the bridge process entirely. It is **not merged** upstream, and its
own author discloses it was "vibe-coded" in a pairing session with an AI
coding tool — this is a deliberate bleeding-edge bet, not a vetted
dependency.

## What this image is

`FROM ghcr.io/blakeblackshear/frigate:0.18.0` with go2rtc rebuilt from
`fzurita/go2rtc@reolink_protocol` (the PR's head branch) at a pinned commit,
replacing the stock go2rtc binary at `/usr/local/go2rtc/bin/go2rtc`. Nothing
else about Frigate changes.

## Updating the pinned commit

`GO2RTC_COMMIT` in the `Dockerfile` is a commit SHA on `fzurita/go2rtc`, not
the branch — the branch moves. Bump it manually by checking
https://github.com/AlexxIT/go2rtc/pull/2263 for the current head SHA.

## Retiring this repo

Once PR #2263 (or equivalent native Baichuan support) merges into
`AlexxIT/go2rtc` and ships in a tagged release, Frigate's own
`docker/main/install_go2rtc.sh` will pull it directly — at that point this
image is no longer needed.
