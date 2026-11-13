#!/bin/sh
# Boot the DOT OS ISO in QEMU on an Apple Silicon Mac (brew install qemu).
#
# Usage: scripts/run-vm.sh [iso]          # live session in a window
#        HEADLESS=1 scripts/run-vm.sh     # no window; QMP socket at out/vm/qmp.sock
#
# A 20 GB disk is created at out/vm/disk.qcow2 for installing to. Delete the
# out/vm folder to start again from an empty disk.
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ISO="${1:-$REPO/out/dot-os-arm64.hybrid.iso}"
VM="$REPO/out/vm"
FW="$(brew --prefix qemu)/share/qemu"
mkdir -p "$VM"
[ -f "$VM/disk.qcow2" ] || qemu-img create -f qcow2 "$VM/disk.qcow2" 20G >/dev/null
[ -f "$VM/vars.fd" ] || cp "$FW/edk2-arm-vars.fd" "$VM/vars.fd"

if [ "${HEADLESS:-0}" = 1 ]; then
	DISPLAY_ARGS="-display none -qmp unix:$VM/qmp.sock,server,nowait -serial file:$VM/serial.log"
else
	DISPLAY_ARGS="-display cocoa,show-cursor=on -serial file:$VM/serial.log"
fi

# shellcheck disable=SC2086
exec qemu-system-aarch64 -machine virt -accel hvf -cpu host -smp 4 -m 4096 \
	-drive if=pflash,format=raw,readonly=on,file="$FW/edk2-aarch64-code.fd" \
	-drive if=pflash,format=raw,file="$VM/vars.fd" \
	-device virtio-gpu-pci,xres=${XRES:-3840},yres=${YRES:-2160} \
	-device qemu-xhci -device usb-kbd -device usb-tablet \
	-drive file="$ISO",media=cdrom,if=none,id=cd,readonly=on -device usb-storage,drive=cd,bootindex=1 \
	-drive file="$VM/disk.qcow2",if=virtio,format=qcow2 \
	-netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
	$DISPLAY_ARGS
