#!/bin/sh
# Keeps the parts that Plasma's Dark/Light switch does not reach in step with
# it: the Kvantum widget theme, the GTK theme, and the stylesheet libadwaita
# apps read. Runs for the whole session: once at login, then again whenever
# Plasma announces a colour change. Apps already open pick up the new widget
# theme when they are next started.
conf="${XDG_CONFIG_HOME:-$HOME/.config}"
mark="$conf/dot-os/variant"

# The Dark/Light switch records the global theme it applied under [KDE]
# LookAndFeelPackage; the colour scheme name is not always written with it.
read_key() {
	for f in "$conf/kdeglobals" /etc/xdg/kdeglobals; do
		s=$(awk -F= -v g="[$1]" -v k="$2" '/^\[/ { in_g = ($0 == g) } in_g && $1 == k { print $2; exit }' "$f" 2>/dev/null)
		[ -n "$s" ] && { echo "$s"; return; }
	done
}

variant() {
	case "$(read_key KDE LookAndFeelPackage)" in
	*.light) echo Light; return ;;
	org.dotos.desktop) echo Dark; return ;;
	esac
	case "$(read_key General ColorScheme)" in
	DotOSLight) echo Light ;;
	*) echo Dark ;;
	esac
}

apply() {
	v=$(variant)
	[ "$(cat "$mark" 2>/dev/null)" = "$v" ] && return

	# Kvantum: the user's own config wins over /etc/xdg.
	mkdir -p "$conf/Kvantum"
	printf '[General]\ntheme=DotOS%s\n' "$v" > "$conf/Kvantum/kvantum.kvconfig"

	# GTK 3 and 4 apps, through Plasma's GTK bridge.
	qdbus6 org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme "DotOS-$v" >/dev/null 2>&1

	# libadwaita apps read ~/.config/gtk-4.0/gtk.css; only ever replace the
	# link DOT OS made, never a user's own file.
	css="$conf/gtk-4.0/gtk.css"
	case "$(readlink "$css" 2>/dev/null)" in
	/usr/share/dot-os/gtk-4.0/*.css)
		lower=$(echo "$v" | tr 'LD' 'ld')
		ln -sfn "/usr/share/dot-os/gtk-4.0/$lower.css" "$css" ;;
	esac

	mkdir -p "$(dirname "$mark")"
	echo "$v" > "$mark"
}

apply
dbus-monitor --session "type='signal',interface='org.kde.KGlobalSettings',member='notifyChange'" 2>/dev/null |
	while read -r line; do
		case "$line" in
		*member=notifyChange*)
			sleep 1
			apply ;;
		esac
	done
