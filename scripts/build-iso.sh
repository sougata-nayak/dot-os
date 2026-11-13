#!/bin/sh
# Build the DOT OS live ISO inside a Debian trixie arm64 container.
#
# live-build cannot run on macOS, and its chroot cannot live on a macOS bind
# mount (no device nodes), so the build tree is kept in a Docker volume and
# only the finished ISO is copied back to ./out.
#
# Usage: scripts/build-iso.sh            # full build
#        LB_CLEAN=1 scripts/build-iso.sh # wipe the cached build tree first
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$REPO/out"
VOLUME="${DOTOS_BUILD_VOLUME:-dot-os-live-build}"
mkdir -p "$OUT"

docker run --rm --privileged --platform linux/arm64 \
	-e LB_CLEAN="${LB_CLEAN:-0}" \
	-v "$REPO":/src:ro \
	-v "$VOLUME":/build \
	-v "$OUT":/out \
	debian:trixie sh -euc '
		export DEBIAN_FRONTEND=noninteractive
		apt-get update -qq
		apt-get install -y -qq --no-install-recommends \
			live-build debootstrap squashfs-tools xorriso mtools dosfstools \
			grub-efi-arm64-bin grub-common ca-certificates cpio rsync >/dev/null
		mkdir -p /build/lb && cd /build/lb
		if [ "$LB_CLEAN" = 1 ] && [ -d auto ]; then lb clean --purge || true; fi
		rsync -a --delete --exclude chroot --exclude cache --exclude binary \
			--exclude ".build" --exclude "*.iso" /src/live-build/ ./
		if [ -d /src/out/debs ]; then
			mkdir -p config/packages.chroot
			cp /src/out/debs/*.deb config/packages.chroot/ 2>/dev/null || true
		fi
		chmod +x auto/*
		lb config
		lb build
		cp -f ./*.iso /out/
		cd /out && sha256sum ./*.iso > SHA256SUMS
		ls -lh /out
	'
