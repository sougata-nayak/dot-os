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
