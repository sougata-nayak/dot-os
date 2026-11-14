#!/bin/sh
# Build DOT OS's patched Calamares inside a Debian trixie arm64 container:
# Debian's own calamares source package plus packages/calamares/patches,
# versioned <debian version>+dotos<N>. The .deb lands in ./out/debs next to
# the theme packages, so the ISO and the APT archive pick it up.
#
# It is a full C++ build (about 15-30 minutes), so it is separate from
# scripts/build-debs.sh. Bump DOTOS_REV when the patches change.
#
# Usage: scripts/build-calamares.sh
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DOTOS_REV=1
mkdir -p "$REPO/out/debs"

docker run --rm --platform linux/arm64 \
	-e DOTOS_REV="$DOTOS_REV" \
	-v "$REPO/packages/calamares":/patches:ro \
	-v "$REPO/out/debs":/out \
	-v dot-os-apt-cache:/var/cache/apt \
	debian:trixie sh -euc '
		export DEBIAN_FRONTEND=noninteractive
		rm -f /etc/apt/apt.conf.d/docker-clean
		sed -i "s/^Types: deb$/Types: deb deb-src/" /etc/apt/sources.list.d/debian.sources
		apt-get update -qq
		apt-get install -y -qq --no-install-recommends build-essential devscripts dpkg-dev quilt >/dev/null
		mkdir /work && cd /work
		apt-get source -qq calamares >/dev/null
		cd calamares-*/
		apt-get build-dep -y -qq . >/dev/null
		mkdir -p debian/patches
		for p in $(cat /patches/patches/series); do
			cp "/patches/patches/$p" debian/patches/
			echo "$p" >> debian/patches/series
		done
		export QUILT_PATCHES=debian/patches
		quilt push -a -q
		version="$(dpkg-parsechangelog -S Version)+dotos$DOTOS_REV"
		DEBFULLNAME="DOT OS project" DEBEMAIL="maintainers@dot-os.invalid" \
			dch -b -v "$version" -D trixie "DOT OS patches: see packages/calamares in the DOT OS repository."
		dpkg-buildpackage -us -uc -b -j"$(nproc)" >/tmp/build.log 2>&1 || { grep -E "error[: ]|Error [0-9]" /tmp/build.log | head -40; exit 1; }
		rm -f /out/calamares_*.deb
		cp ../calamares_*.deb /out/
		ls -l /out/calamares_*.deb
	'
