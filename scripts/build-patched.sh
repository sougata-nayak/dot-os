#!/bin/sh
# Build DOT OS's patched copies of Debian packages inside a Debian trixie
# arm64 container. Each one is Debian's own source package plus the patches
# in packages/<name>/patches, versioned <debian version>+dotos<N>.
#
# A patched package is a folder under packages/ holding:
#   source    the Debian source package name
#   rev       the DOT OS revision N; bump it when the patches change
#   debs      the binary packages to keep, one per line (the rest are stock)
#   patches/  a quilt series
#
# The .debs land in ./out/debs next to the theme packages, so the ISO and the
# APT archive pick them up. These are full C++ builds (5-30 minutes each),
# which is why they are not part of scripts/build-debs.sh.
#
# Usage: scripts/build-patched.sh [name ...]     (default: all of them)
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO/out/debs"

if [ $# -eq 0 ]; then
	set -- $(cd "$REPO/packages" && for d in */; do [ -f "$d/source" ] && echo "${d%/}"; done)
fi

for name in "$@"; do
	dir="$REPO/packages/$name"
	[ -f "$dir/source" ] || { echo "packages/$name is not a patched package" >&2; exit 1; }
	echo "== $name"
	docker run --rm --platform linux/arm64 \
		-e DOTOS_SOURCE="$(cat "$dir/source")" \
		-e DOTOS_REV="$(cat "$dir/rev")" \
		-v "$dir":/patches:ro \
		-v "$REPO/out/debs":/out \
		-v dot-os-apt-cache:/var/cache/apt \
		debian:trixie sh -euc '
			export DEBIAN_FRONTEND=noninteractive
			rm -f /etc/apt/apt.conf.d/docker-clean
			sed -i "s/^Types: deb$/Types: deb deb-src/" /etc/apt/sources.list.d/debian.sources
			apt-get update -qq
			apt-get install -y -qq --no-install-recommends build-essential devscripts dpkg-dev quilt >/dev/null
			mkdir /work && cd /work
			apt-get source -qq "$DOTOS_SOURCE" >/dev/null
			cd "$(find . -mindepth 1 -maxdepth 1 -type d)"
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
				dch -b -v "$version" -D trixie "DOT OS patches: see packages/ in the DOT OS repository."
			DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc -b -j"$(nproc)" >/tmp/build.log 2>&1 || { grep -E "error[: ]|Error [0-9]" /tmp/build.log | head -40; exit 1; }
			for deb in $(cat /patches/debs); do
				rm -f /out/"$deb"_*.deb
				cp ../"$deb"_*.deb /out/
				ls -l /out/"$deb"_*.deb
			done
		'
done
