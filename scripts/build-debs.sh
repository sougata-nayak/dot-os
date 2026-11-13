#!/bin/sh
# Build every package under packages/ that has a debian/ directory, inside a
# Debian trixie arm64 container. Finished .deb files land in ./out/debs.
#
# Usage: scripts/build-debs.sh [package-dir ...]
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$REPO/out/debs"

docker run --rm --platform linux/arm64 \
	-v "$REPO":/src:ro \
	-v "$REPO/out/debs":/out \
	-v dot-os-apt-cache:/var/cache/apt \
	debian:trixie sh -euc '
		export DEBIAN_FRONTEND=noninteractive
		rm -f /etc/apt/apt.conf.d/docker-clean
		apt-get update -qq
		apt-get install -y -qq --no-install-recommends \
			build-essential debhelper devscripts librsvg2-bin x11-apps lintian \
			python3 python3-fonttools grub-common >/dev/null
		mkdir /work && cp -a /src/packages /src/tools /src/design-system /work/
		cd /work/packages
		wanted="$*"
		for dir in */; do
			dir=${dir%/}
			[ -d "$dir/debian" ] || continue
			if [ -n "$wanted" ]; then case " $wanted " in *" $dir "*) ;; *) continue ;; esac; fi
			echo "=== $dir"
			(cd "$dir" && dpkg-buildpackage -us -uc -b >/tmp/build.log 2>&1) || { cat /tmp/build.log; exit 1; }
		done
		for deb in ./*.deb; do rm -f /out/"$(dpkg-deb -f "$deb" Package)"_*.deb; done
		cp ./*.deb /out/
		for deb in /out/*.deb; do
			printf "%s  %s files\n" "$(basename "$deb")" "$(dpkg-deb -c "$deb" | grep -vc "/$")"
		done
		lintian --no-tag-display-limit /out/*.deb 2>&1 | grep -E "^E:" || echo "lintian: no errors"
	' sh "$@"
