#!/bin/sh
# Create the DOT OS archive signing key (once).
#
#   keys/dot-os-archive.private.asc   SECRET. Never commit it. Keep a backup
#                                     somewhere safe and add it to GitHub as
#                                     the DOTOS_SIGNING_KEY Actions secret.
#   packages/dot-os-archive-keyring/files/dot-os-archive-keyring.asc
#                                     the public half, shipped to every
#                                     DOT OS machine.
set -eu
REPO="$(cd "$(dirname "$0")/.." && pwd)"
if [ -e "$REPO/keys/dot-os-archive.private.asc" ]; then
	echo "keys/dot-os-archive.private.asc already exists; not replacing it." >&2
	exit 1
fi
mkdir -p "$REPO/keys"
chmod 700 "$REPO/keys"
docker run --rm --platform linux/arm64 -v "$REPO":/src -v dot-os-apt-cache:/var/cache/apt debian:trixie sh -euc '
	rm -f /etc/apt/apt.conf.d/docker-clean
	apt-get update -qq && apt-get install -y -qq gnupg >/dev/null 2>&1
	export GNUPGHOME=$(mktemp -d)
	gpg --batch --quiet --passphrase "" --quick-generate-key "DOT OS archive signing key" ed25519 sign 3y
	fpr=$(gpg --batch --with-colons --list-secret-keys | awk -F: "/^fpr/{print \$10; exit}")
	umask 077
	gpg --batch --armor --export-secret-keys "$fpr" > /src/keys/dot-os-archive.private.asc
	gpg --batch --armor --export "$fpr" > /src/packages/dot-os-archive-keyring/files/dot-os-archive-keyring.asc
	echo "$fpr" > /src/keys/fingerprint
	echo "Created key $fpr"
'
