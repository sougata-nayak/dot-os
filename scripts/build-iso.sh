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
		# Always start the chroot fresh so new or changed packages are installed;
		# LB_CLEAN=1 also drops the package cache.
		if [ -d auto ]; then
			if [ "$LB_CLEAN" = 1 ]; then lb clean --purge || true; else lb clean || true; fi
		fi
		rsync -a --delete --exclude chroot --exclude cache --exclude binary \
			--exclude ".build" --exclude "*.iso" /src/live-build/ ./
		rm -rf config/packages.chroot config/bootloaders/grub-pc/dot-os
		if ls /src/out/debs/*.deb >/dev/null 2>&1; then
			mkdir -p config/packages.chroot
			cp /src/out/debs/*.deb config/packages.chroot/
			# The live boot menu reads its theme from the ISO, not the chroot.
			theme_deb=$(ls /src/out/debs/dot-os-grub-theme_*.deb 2>/dev/null | head -1)
			if [ -n "$theme_deb" ]; then
				mkdir -p /tmp/grub-theme
				dpkg-deb -x "$theme_deb" /tmp/grub-theme
				cp -a /tmp/grub-theme/boot/grub/themes/dot-os config/bootloaders/grub-pc/dot-os
			fi
		else
			echo "No packages in out/debs: building a plain, unthemed image." >&2
		fi
		chmod +x auto/*
		lb config
		lb build
		cp -f ./*.iso /out/
		cd /out && sha256sum ./*.iso > SHA256SUMS
		ls -lh /out
	'
