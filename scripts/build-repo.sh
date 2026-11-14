#!/bin/sh
# Build the signed DOT OS APT archive from out/debs into out/repo/apt.
#
# The signing key comes from $DOTOS_SIGNING_KEY (an armored private key, as
# in CI) or keys/dot-os-archive.private.asc. The result is a static tree that
# can be served from GitHub Pages at /apt.
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
KEYFILE="$REPO/keys/dot-os-archive.private.asc"
if [ -n "${DOTOS_SIGNING_KEY:-}" ]; then
	KEYDIR=$(mktemp -d)
	printf '%s\n' "$DOTOS_SIGNING_KEY" > "$KEYDIR/key.asc"
	KEYFILE="$KEYDIR/key.asc"
fi
[ -f "$KEYFILE" ] || { echo "No signing key: run scripts/make-signing-key.sh or set DOTOS_SIGNING_KEY." >&2; exit 1; }
ls "$REPO"/out/debs/*.deb >/dev/null 2>&1 || { echo "No packages in out/debs: run scripts/build-debs.sh first." >&2; exit 1; }
rm -rf "$REPO/out/repo"
mkdir -p "$REPO/out/repo"

docker run --rm --platform linux/arm64 \
	-v "$REPO/out/debs":/debs:ro -v "$KEYFILE":/key.asc:ro -v "$REPO/out/repo":/out \
	-v "$REPO/packages/dot-os-archive-keyring/files":/pub:ro -v dot-os-apt-cache:/var/cache/apt \
	debian:trixie sh -euc '
		rm -f /etc/apt/apt.conf.d/docker-clean
		apt-get update -qq && apt-get install -y -qq reprepro gnupg >/dev/null 2>&1
		export GNUPGHOME=$(mktemp -d)
		gpg --batch --quiet --import /key.asc
		fpr=$(gpg --batch --with-colons --list-secret-keys | awk -F: "/^fpr/{print \$10; exit}")
		mkdir -p /tmp/apt/conf
		cat > /tmp/apt/conf/distributions <<CONF
Origin: DOT OS
Label: DOT OS
Codename: trixie
Suite: stable
Architectures: arm64 amd64
Components: main
Description: DOT OS desktop packages, built on Debian 13
SignWith: $fpr
CONF
		reprepro -b /tmp/apt --silent includedeb trixie /debs/*.deb
		rm -rf /tmp/apt/db /tmp/apt/conf
		cp /pub/dot-os-archive-keyring.asc /tmp/apt/dot-os-archive-keyring.asc
		cp -a /tmp/apt /out/apt
		echo "Signed with $fpr"
		find /out/apt -name "*.deb" | wc -l | sed "s/^/packages: /"
	'
