#!/bin/sh
# Rasterise the cursor SVGs and pack them into Xcursor files.
# Needs rsvg-convert (librsvg2-bin) and xcursorgen (x11-apps).
set -eu
cd "$(dirname "$0")"
rm -rf build
for theme in src/*/; do
	name=$(basename "$theme")
	work="build/.work/$name"
	out="build/$name"
	mkdir -p "$out/cursors" "$work"
	for size in 24 32 36 48 64 72 96; do
		mkdir -p "$work/png/$size"
		for svg in "$theme"svg/*.svg; do
			rsvg-convert -w "$size" -h "$size" "$svg" -o "$work/png/$size/$(basename "$svg" .svg).png"
		done
	done
	for cfg in "$theme"config/*.cursor; do
		xcursorgen -p "$work" "$cfg" "$out/cursors/$(basename "$cfg" .cursor)"
	done
	while read -r alias target; do
		ln -sf "$target" "$out/cursors/$alias"
	done < "$theme/aliases"
	# Scalable cursors: one folder per cursor with its SVG frames and metadata.
	for meta in "$theme"scalable/*.json; do
		cursor=$(basename "$meta" .json)
		mkdir -p "$out/cursors_scalable/$cursor"
		cp "$meta" "$out/cursors_scalable/$cursor/metadata.json"
		cp "$theme"svg/"$cursor".svg "$theme"svg/"$cursor"-[0-9][0-9].svg "$out/cursors_scalable/$cursor/" 2>/dev/null || true
	done
	while read -r alias target; do
		ln -sfn "$target" "$out/cursors_scalable/$alias"
	done < "$theme/aliases"
	cp "$theme/index.theme" "$out/index.theme"
done
rm -rf build/.work
