#!/bin/sh
# Runs at login, once per user, for the two GTK settings Plasma's global
# theme cannot carry.
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
[ -e "$conf/dot-os-session-setup" ] && exit 0

# libadwaita apps ignore GTK themes and only read the user's own gtk.css.
css="$conf/gtk-4.0/gtk.css"
if [ ! -e "$css" ] && [ ! -L "$css" ]; then
	mkdir -p "$(dirname "$css")"
	ln -s /usr/share/dot-os/gtk-4.0/dark.css "$css"
fi

# Plasma's GTK bridge defaults to Breeze; point it at the DOT OS theme.
for try in 1 2 3 4 5 6; do
	if qdbus6 org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme DotOS-Dark >/dev/null 2>&1; then
		: > "$conf/dot-os-session-setup"
		exit 0
	fi
	sleep 5
done
