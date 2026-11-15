#!/bin/sh
# Runs at every login; each step runs once per user and leaves a marker in
# ~/.config/dot-os/.
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
mark="$conf/dot-os"
mkdir -p "$mark"

# libadwaita apps ignore GTK themes and only read the user's own gtk.css.
css="$conf/gtk-4.0/gtk.css"
if [ ! -e "$css" ] && [ ! -L "$css" ]; then
	mkdir -p "$(dirname "$css")"
	ln -s /usr/share/dot-os/gtk-4.0/dark.css "$css"
fi

# App window layouts (which toolbars show). Copied once; files the user
# already has are left alone.
if [ ! -e "$mark/app-layouts" ]; then
	# Konsole's own first-run update turns its menu bar on when it finds the
	# toolbars hidden, unless the user's konsolerc already has a MenuBar line.
	# Write that line before the layouts that hide the toolbars, and by hand:
	# kwriteconfig6 skips a value equal to the /etc/xdg default, which leaves
	# no line at all. Ctrl+Shift+M still brings the menu bar back.
	grep -qs '^MenuBar=' "$conf/konsolerc" ||
		printf '\n[MainWindow]\nMenuBar=Disabled\n' >> "$conf/konsolerc"
	data="${XDG_DATA_HOME:-$HOME/.local/share}/kxmlgui5"
	for f in /usr/share/dot-os/kxmlgui5/*/*.rc; do
		[ -e "$f" ] || continue
		rel="${f#/usr/share/dot-os/kxmlgui5/}"
		[ -e "$data/$rel" ] || install -D -m 644 "$f" "$data/$rel"
	done
	: > "$mark/app-layouts"
fi

# Plasma's GTK bridge defaults to Breeze; point it at the DOT OS theme.
if [ ! -e "$mark/gtk-theme" ]; then
	for try in 1 2 3 4 5 6; do
		if qdbus6 org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme DotOS-Dark >/dev/null 2>&1; then
			: > "$mark/gtk-theme"
			break
		fi
		sleep 5
	done
fi

# Default display: 3840x2160 at 250% on any screen that offers that mode.
# Smaller screens keep the mode and scale KWin picks for them.
if [ ! -e "$mark/display" ]; then
	sleep 3
	if args=$(/usr/bin/python3 /usr/share/dot-os/display-defaults.py); then
		[ -n "$args" ] && kscreen-doctor $args >/dev/null 2>&1
		: > "$mark/display"
	fi
fi
