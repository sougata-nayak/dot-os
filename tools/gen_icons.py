"""Icon theme: freedesktop icon names mapped onto Lucide glyphs, redrawn at the
DOT OS stroke (1.5px on a 24px grid) and coloured by the KDE colour scheme.

Lucide sources are vendored in packages/icon-theme/lucide/ (ISC licence).
Set LUCIDE_DIR to an unpacked lucide-static `icons/` folder to (re)vendor.
"""
import os
import re
import shutil

from tokens import ROOT, THEMES, write

VENDOR = os.path.join(ROOT, "packages", "icon-theme", "lucide")

# context -> {freedesktop name: lucide name}
MAP = {
    "apps": {
        "utilities-terminal": "terminal", "org.kde.konsole": "terminal", "konsole": "terminal",
        "system-file-manager": "folder", "org.kde.dolphin": "folder", "dolphin": "folder",
        "internet-web-browser": "globe", "web-browser": "globe", "firefox": "globe", "firefox-esr": "globe",
        "konqueror": "globe", "chromium": "globe",
        "internet-mail": "mail", "mail-client": "mail", "kmail": "mail", "thunderbird": "mail",
        "accessories-text-editor": "file-text", "org.kde.kwrite": "file-text", "kwrite": "file-text",
        "org.kde.kate": "file-text", "kate": "file-text",
        "preferences-system": "settings", "systemsettings": "settings", "org.kde.systemsettings": "settings",
        "system-software-install": "package", "plasmadiscover": "package", "org.kde.discover": "package",
        "multimedia-audio-player": "music", "multimedia-video-player": "film",
        "accessories-calculator": "calculator", "org.kde.kcalc": "calculator", "kcalc": "calculator",
        "help-browser": "circle-help", "org.kde.khelpcenter": "circle-help",
        "utilities-system-monitor": "activity", "org.kde.plasma-systemmonitor": "activity",
        "calamares": "hard-drive-download", "install-debian": "hard-drive-download",
        "accessories-screenshot": "camera", "org.kde.spectacle": "camera", "spectacle": "camera",
        "image-viewer": "image", "org.kde.gwenview": "image", "gwenview": "image",
        "document-viewer": "book-open", "org.kde.okular": "book-open", "okular": "book-open",
        "utilities-file-archiver": "archive", "org.kde.ark": "archive", "ark": "archive",
        "kwalletmanager": "key-round", "org.kde.kwalletmanager": "key-round",
        "system-users": "users", "kinfocenter": "info", "org.kde.kinfocenter": "info",
        "partitionmanager": "hard-drive", "org.kde.partitionmanager": "hard-drive",
        "preferences-desktop-theme": "palette", "preferences-desktop-color": "palette",
        "preferences-desktop-display": "monitor", "preferences-desktop-keyboard": "keyboard",
        "preferences-desktop-notification": "bell", "preferences-desktop-sound": "volume-2",
        "preferences-desktop-wallpaper": "image", "preferences-desktop-font": "type",
        "preferences-desktop-locale": "languages", "preferences-desktop-user": "user",
        "preferences-desktop-accessibility": "accessibility", "preferences-system-network": "network",
        "preferences-system-bluetooth": "bluetooth", "preferences-system-time": "clock",
        "preferences-system-power-management": "battery-charging", "preferences-desktop": "monitor",
        "start-here": "grip", "start-here-kde": "grip", "start-here-kde-plasma": "grip", "plasma": "grip",
    },
    "places": {
        "folder": "folder", "folder-open": "folder-open", "inode-directory": "folder",
        "user-home": "house", "folder-home": "house", "user-desktop": "monitor", "folder-desktop": "monitor",
        "folder-documents": "file", "folder-document": "file", "folder-download": "download",
        "folder-downloads": "download", "folder-pictures": "image", "folder-image": "image",
        "folder-videos": "film", "folder-video": "film", "folder-music": "music", "folder-sound": "music",
        "folder-templates": "folder", "folder-publicshare": "folder", "folder-public": "folder",
        "network-workgroup": "network", "folder-remote": "network", "folder-network": "network",
        "network-server": "server", "user-trash": "trash-2", "user-trash-full": "trash-2",
        "folder-favorites": "star", "folder-bookmark": "bookmark", "folder-recent": "clock",
        "document-open-recent": "clock", "folder-root": "hard-drive", "folder-locked": "lock",
        "folder-cloud": "cloud", "folder-git": "git-branch", "folder-script": "terminal",
    },
    "devices": {
        "drive-harddisk": "hard-drive", "drive-harddisk-root": "hard-drive", "drive-removable-media": "usb",
        "drive-removable-media-usb": "usb", "media-removable": "usb", "media-flash": "usb",
        "drive-optical": "disc", "media-optical": "disc", "computer": "monitor", "video-display": "monitor",
        "computer-laptop": "laptop", "input-keyboard": "keyboard", "input-mouse": "mouse",
        "input-touchpad": "mouse", "input-gaming": "gamepad-2", "input-tablet": "tablet",
        "printer": "printer", "scanner": "scan", "camera-photo": "camera", "camera-web": "webcam",
        "audio-card": "volume-2", "audio-speakers": "speaker", "audio-headphones": "headphones",
        "audio-headset": "headphones", "audio-input-microphone": "mic", "phone": "smartphone",
        "smartphone": "smartphone", "tablet": "tablet", "network-wired": "ethernet-port",
        "network-wireless": "wifi", "battery": "battery-medium", "cpu": "cpu", "device_mem": "memory-stick",
        "bluetooth": "bluetooth",
    },
    "actions": {
        "document-new": "file-plus", "document-open": "folder-open", "document-save": "save",
        "document-save-as": "save", "document-save-all": "save", "document-print": "printer",
        "document-print-preview": "printer", "document-properties": "sliders-horizontal",
        "document-edit": "pencil", "document-send": "send", "document-share": "share-2",
        "document-export": "upload", "document-import": "download", "document-close": "x",
        "document-revert": "undo-2", "document-encrypt": "lock", "document-decrypt": "lock-open",
        "document-open-folder": "folder-open", "document-preview": "eye",
        "edit-copy": "copy", "edit-cut": "scissors", "edit-paste": "clipboard", "edit-delete": "trash-2",
        "edit-undo": "undo-2", "edit-redo": "redo-2", "edit-find": "search", "edit-find-replace": "replace",
        "edit-clear": "x", "edit-clear-all": "x", "edit-clear-history": "eraser", "edit-rename": "pencil",
        "edit-entry": "pencil", "edit-select-all": "square-dashed", "edit-download": "download",
        "edit-link": "link", "edit-reset": "rotate-ccw", "delete": "trash-2", "trash-empty": "trash",
        "go-previous": "chevron-left", "go-next": "chevron-right", "go-up": "chevron-up",
        "go-down": "chevron-down", "go-home": "house", "go-first": "chevrons-left", "go-last": "chevrons-right",
        "go-top": "chevrons-up", "go-bottom": "chevrons-down", "go-jump": "corner-down-right",
        "go-parent-folder": "chevron-up", "arrow-left": "chevron-left", "arrow-right": "chevron-right",
        "arrow-up": "chevron-up", "arrow-down": "chevron-down",
        "view-refresh": "refresh-cw", "view-list-details": "list", "view-list-icons": "layout-grid",
        "view-list-tree": "list-tree", "view-list-text": "list", "view-fullscreen": "maximize",
        "view-restore": "minimize", "view-hidden": "eye-off", "view-visible": "eye",
        "view-sort": "arrow-up-down", "view-sort-ascending": "arrow-up-narrow-wide",
        "view-sort-descending": "arrow-down-wide-narrow", "view-filter": "list-filter",
        "view-split-left-right": "columns-2", "view-split-top-bottom": "rows-2", "view-preview": "eye",
        "view-calendar": "calendar", "view-grid": "layout-grid", "view-sidetree": "panel-left",
        "sidebar-expand-left": "panel-left", "sidebar-collapse-left": "panel-left",
        "list-add": "plus", "list-remove": "minus", "list-add-user": "user-plus", "list-remove-user": "user-minus",
        "window-close": "x", "window-minimize": "minus", "window-maximize": "square", "window-restore": "copy",
        "window-new": "app-window", "dialog-ok": "check", "dialog-ok-apply": "check", "dialog-cancel": "x",
        "dialog-close": "x", "dialog-apply": "check", "application-exit": "log-out", "application-menu": "menu",
        "open-menu": "menu", "overflow-menu": "ellipsis-vertical", "view-more": "ellipsis",
        "system-run": "play", "system-search": "search", "search": "search", "configure": "settings",
        "settings-configure": "settings", "configure-shortcuts": "keyboard", "configure-toolbars": "settings",
        "help-about": "info", "help-contents": "circle-help", "help-hint": "lightbulb",
        "tools-report-bug": "bug", "tools": "wrench", "run-build": "hammer", "run-install": "download",
        "media-playback-start": "play", "media-playback-pause": "pause", "media-playback-stop": "square",
        "media-skip-forward": "skip-forward", "media-skip-backward": "skip-back",
        "media-seek-forward": "fast-forward", "media-seek-backward": "rewind", "media-record": "circle",
        "media-eject": "arrow-up-from-line", "zoom-in": "zoom-in", "zoom-out": "zoom-out",
        "zoom-original": "search", "zoom-fit-best": "maximize",
        "bookmark-new": "bookmark", "bookmarks": "bookmark", "mail-send": "send", "mail-message-new": "mail-plus",
        "mail-reply-sender": "reply", "mail-forward": "forward", "download": "download",
        "folder-new": "folder-plus", "tab-new": "plus", "tab-close": "x", "tab-duplicate": "copy",
        "object-locked": "lock", "object-unlocked": "lock-open", "object-rotate-right": "rotate-cw",
        "object-rotate-left": "rotate-ccw", "object-flip-horizontal": "flip-horizontal",
        "object-flip-vertical": "flip-vertical", "insert-link": "link", "insert-image": "image-plus",
        "transform-move": "move", "transform-crop": "crop", "draw-freehand": "pencil",
        "dialog-password": "key-round", "appointment-new": "calendar-plus", "clock": "clock", "chronometer": "timer",
        "system-lock-screen": "lock", "system-log-out": "log-out", "system-shutdown": "power",
        "system-reboot": "rotate-cw", "system-suspend": "moon", "system-suspend-hibernate": "moon",
        "system-switch-user": "users", "im-user": "user", "user": "user", "user-identity": "user",
        "contact-new": "user-plus", "favorite": "star", "emblem-favorite": "star", "rating": "star",
        "color-picker": "pipette", "format-text-bold": "bold", "format-text-italic": "italic",
        "format-text-underline": "underline", "format-justify-left": "align-left",
        "format-justify-center": "align-center", "format-justify-right": "align-right",
        "code-context": "code", "terminal": "terminal", "utilities-terminal": "terminal",
        "network-connect": "plug", "network-disconnect": "unplug", "notifications": "bell",
        "pin": "pin", "window-pin": "pin", "window-unpin": "pin-off", "edit-select": "mouse-pointer",
        "globe": "globe", "internet-services": "globe", "password-show-on": "eye", "password-show-off": "eye-off",
        "visibility": "eye", "hint": "eye-off", "adjustlevels": "sliders-horizontal", "exchange-positions": "arrow-left-right",
    },
    "status": {
        "dialog-information": "info", "dialog-warning": "triangle-alert", "dialog-error": "circle-x",
        "dialog-question": "circle-help", "dialog-password": "key-round", "dialog-positive": "circle-check",
        "data-information": "info", "data-warning": "triangle-alert", "data-error": "circle-x",
        "data-success": "circle-check", "emblem-warning": "triangle-alert", "emblem-error": "circle-x",
        "emblem-information": "info", "emblem-success": "circle-check",
        "network-wireless-connected-100": "wifi", "network-wireless-connected-75": "wifi",
        "network-wireless-connected-50": "wifi-high", "network-wireless-connected-25": "wifi-low",
        "network-wireless-connected-00": "wifi-zero", "network-wireless-signal-excellent": "wifi",
        "network-wireless-signal-good": "wifi-high", "network-wireless-signal-ok": "wifi-low",
        "network-wireless-signal-weak": "wifi-zero", "network-wireless-signal-none": "wifi-zero",
        "network-wireless-100": "wifi", "network-wireless-80": "wifi", "network-wireless-60": "wifi-high",
        "network-wireless-40": "wifi-low", "network-wireless-20": "wifi-zero", "network-wireless-0": "wifi-zero",
        "network-wireless-disconnected": "wifi-off", "network-wireless-off": "wifi-off",
        "network-wireless-available": "wifi", "network-wireless-on": "wifi",
        "network-wired-activated": "ethernet-port", "network-wired-available": "ethernet-port",
        "network-wired-unavailable": "unplug", "network-offline": "wifi-off", "network-unavailable": "wifi-off",
        "network-flightmode-on": "plane", "network-vpn": "shield-check", "network-bluetooth": "bluetooth",
        "network-bluetooth-activated": "bluetooth", "network-bluetooth-inactive": "bluetooth-off",
        "audio-volume-high": "volume-2", "audio-volume-medium": "volume-1", "audio-volume-low": "volume",
        "audio-volume-muted": "volume-x", "audio-on": "volume-2", "audio-off": "volume-x", "audio-ready": "volume-2",
        "microphone-sensitivity-high": "mic", "microphone-sensitivity-medium": "mic",
        "microphone-sensitivity-low": "mic", "microphone-sensitivity-muted": "mic-off", "mic-on": "mic",
        "mic-off": "mic-off", "mic-ready": "mic",
        "battery-100": "battery-full", "battery-090": "battery-full", "battery-080": "battery-full",
        "battery-070": "battery-medium", "battery-060": "battery-medium", "battery-050": "battery-medium",
        "battery-040": "battery-low", "battery-030": "battery-low", "battery-020": "battery-low",
        "battery-010": "battery-warning", "battery-000": "battery-warning", "battery-full": "battery-full",
        "battery-good": "battery-medium", "battery-low": "battery-low", "battery-caution": "battery-warning",
        "battery-empty": "battery", "battery-missing": "battery", "battery-full-charging": "battery-charging",
        "battery-good-charging": "battery-charging", "battery-low-charging": "battery-charging",
        "battery-caution-charging": "battery-charging", "battery-empty-charging": "battery-charging",
        "battery-100-charging": "battery-charging", "battery-080-charging": "battery-charging",
        "battery-060-charging": "battery-charging", "battery-040-charging": "battery-charging",
        "battery-020-charging": "battery-charging", "battery-000-charging": "battery-charging",
        "battery-charging": "battery-charging", "battery-profile-performance": "zap",
        "battery-profile-powersave": "leaf", "bluetooth-active": "bluetooth", "bluetooth-disabled": "bluetooth-off",
        "preferences-system-bluetooth-activated": "bluetooth", "preferences-system-bluetooth-inactive": "bluetooth-off",
        "notifications": "bell", "notifications-disabled": "bell-off", "notification-active": "bell",
        "notification-inactive": "bell", "notification-disabled": "bell-off",
        "security-high": "shield-check", "security-medium": "shield", "security-low": "shield-alert",
        "object-locked": "lock", "object-unlocked": "lock-open", "mail-unread": "mail", "mail-read": "mail-open",
        "media-playlist-shuffle": "shuffle", "media-playlist-repeat": "repeat", "process-working": "loader",
        "image-missing": "image-off", "image-loading": "image", "printer-error": "printer", "printer-printing": "printer",
        "brightness-high": "sun", "brightness-low": "sun-dim", "display-brightness": "sun",
        "video-display-brightness": "sun", "redshift-status-on": "moon", "redshift-status-off": "sun",
        "redshift-status-day": "sun", "weather-clear": "sun", "weather-clear-night": "moon",
        "weather-clouds": "cloud", "weather-showers": "cloud-rain", "weather-snow": "cloud-snow",
        "weather-storm": "cloud-lightning", "airplane-mode": "plane", "airplane-mode-on": "plane",
        "update-none": "check", "update-low": "download", "update-medium": "download", "update-high": "download",
        "software-update-available": "download", "system-software-update": "download",
        "state-ok": "check", "state-warning": "triangle-alert", "state-error": "circle-x",
        "state-information": "info", "task-complete": "check", "task-attention": "circle-alert",
        "user-available": "circle", "user-away": "clock", "user-busy": "circle-minus", "user-offline": "circle-dashed",
        "user-trash-full": "trash-2", "folder-open": "folder-open", "input-keyboard-virtual": "keyboard",
        "touchpad-enabled": "mouse", "touchpad-disabled": "mouse-off", "media-record": "circle",
        "klipper": "clipboard", "clipboard": "clipboard", "kdeconnect": "smartphone", "device-notifier": "usb",
        "system-search": "search", "appointment-missed": "calendar-x", "appointment-soon": "calendar-clock",
    },
    "mimetypes": {
        "text-plain": "file-text", "text-x-generic": "file-text", "text-markdown": "file-text",
        "text-x-readme": "file-text", "x-office-document": "file-text", "application-pdf": "file-text",
        "application-octet-stream": "file", "unknown": "file", "none": "file", "empty": "file",
        "application-x-executable": "file-terminal", "text-x-script": "file-terminal",
        "application-x-shellscript": "file-terminal", "application-x-desktop": "app-window",
        "image-x-generic": "file-image", "image-png": "file-image", "image-jpeg": "file-image",
        "image-svg+xml": "file-image", "audio-x-generic": "file-audio", "video-x-generic": "file-video",
        "package-x-generic": "package", "application-x-deb": "package", "application-vnd.debian.binary-package": "package",
        "application-x-rpm": "package", "application-zip": "file-archive", "application-x-archive": "file-archive",
        "application-x-tar": "file-archive", "application-x-compressed-tar": "file-archive",
        "application-x-7z-compressed": "file-archive", "application-gzip": "file-archive",
        "text-html": "file-code", "text-css": "file-code", "text-x-python": "file-code", "text-x-csrc": "file-code",
        "text-x-c++src": "file-code", "application-javascript": "file-code", "text-x-qml": "file-code",
        "application-xml": "file-code", "application-json": "file-json", "application-x-yaml": "file-code",
        "application-x-iso": "disc", "application-x-cd-image": "disc", "application-x-raw-disk-image": "disc",
        "inode-directory": "folder", "font-x-generic": "file-type", "application-x-font-ttf": "file-type",
        "application-x-font-otf": "file-type", "x-office-spreadsheet": "file-spreadsheet",
        "text-csv": "file-spreadsheet", "x-office-presentation": "presentation", "x-office-calendar": "calendar",
        "x-office-address-book": "book-user", "application-pgp-keys": "key-round",
        "application-x-trash": "trash-2", "text-x-log": "scroll-text", "text-x-changelog": "scroll-text",
        "application-x-kvantum": "palette", "text-x-patch": "file-diff", "application-x-sqlite3": "database",
    },
    "categories": {
        "applications-all": "grip", "applications-internet": "globe", "applications-multimedia": "music",
        "applications-graphics": "image", "applications-development": "code", "applications-games": "gamepad-2",
        "applications-office": "briefcase", "applications-system": "settings", "applications-utilities": "wrench",
        "applications-education": "graduation-cap", "applications-science": "flask-conical",
        "applications-other": "ellipsis", "applications-accessories": "wrench", "applications-engineering": "wrench",
        "preferences-system": "settings", "preferences-desktop": "monitor", "preferences-other": "settings",
        "preferences-desktop-personal": "user", "preferences-desktop-peripherals": "keyboard",
        "system-help": "circle-help",
    },
    "emblems": {
        "emblem-symbolic-link": "link", "emblem-readonly": "lock", "emblem-locked": "lock",
        "emblem-unlocked": "lock-open", "emblem-favorite": "star", "emblem-important": "circle-alert",
        "emblem-default": "check", "emblem-shared": "share-2", "emblem-mounted": "check",
        "emblem-unmounted": "minus", "emblem-downloads": "download", "emblem-added": "plus", "emblem-remove": "minus",
    },
}

CONTEXT = {"apps": "Applications", "places": "Places", "devices": "Devices", "actions": "Actions",
           "status": "Status", "mimetypes": "MimeTypes", "categories": "Categories", "emblems": "Emblems"}


def inner(lucide_name):
    with open(os.path.join(VENDOR, lucide_name + ".svg")) as fh:
        text = fh.read()
    body = re.search(r"<svg[^>]*>(.*)</svg>", text, re.S).group(1)
    return re.sub(r"\s+", " ", body).strip()


# Contexts drawn large (file views, launchers) get a second, lighter cut so
# the stroke stays near 1.5-2px on screen instead of scaling up with the icon.
LARGE = ("apps", "places", "devices", "mimetypes", "categories")


def render(lucide_name, colour, stroke="1.5"):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">'
            '<style type="text/css" id="current-color-scheme">.ColorScheme-Text{color:%s;}</style>'
            '<g class="ColorScheme-Text" fill="none" stroke="currentColor" stroke-width="%s" '
            'stroke-linecap="round" stroke-linejoin="round">%s</g></svg>\n' % (colour, stroke, inner(lucide_name)))


def vendor():
    """Copy the Lucide sources we map to into the repo."""
    src = os.environ.get("LUCIDE_DIR")
    if not src:
        return
    os.makedirs(VENDOR, exist_ok=True)
    wanted = {l for ctx in MAP.values() for l in ctx.values()}
    missing = sorted(n for n in wanted if not os.path.exists(os.path.join(src, n + ".svg")))
    if missing:
        raise SystemExit("Lucide has no icon named: " + ", ".join(missing))
    for stale in os.listdir(VENDOR):
        if stale.endswith(".svg") and stale[:-4] not in wanted:
            os.remove(os.path.join(VENDOR, stale))
    for name in wanted:
        shutil.copyfile(os.path.join(src, name + ".svg"), os.path.join(VENDOR, name + ".svg"))
    licence = os.path.join(os.path.dirname(src.rstrip("/")), "LICENSE")
    if os.path.exists(licence):
        shutil.copyfile(licence, os.path.join(VENDOR, "LICENSE"))


def index(theme):
    dirs = ["%s/scalable" % ctx for ctx in MAP] + ["%s/large" % ctx for ctx in LARGE]
    out = ["[Icon Theme]", "Name=DOT OS" + ("" if theme == "dark" else " Light"),
           "Comment=Monoline icons at a 1.5px stroke, drawn from Lucide",
           "Inherits=breeze-dark,breeze,hicolor" if theme == "dark" else "Inherits=breeze,hicolor",
           "Example=folder", "FollowsColorScheme=true", "DesktopDefault=48", "DesktopSizes=16,22,32,48,64,128,256",
           "ToolbarDefault=22", "ToolbarSizes=16,22,32,48", "MainToolbarDefault=22", "MainToolbarSizes=16,22,32,48",
           "SmallDefault=16", "SmallSizes=16,22,32,48", "PanelDefault=48", "PanelSizes=16,22,32,48,64,128,256",
           "DialogDefault=32", "DialogSizes=16,22,32,48,64,128,256", "Directories=" + ",".join(dirs), ""]
    for ctx in MAP:
        small_max = 32 if ctx in LARGE else 512
        out += ["[%s/scalable]" % ctx, "Size=24", "MinSize=8", "MaxSize=%d" % small_max, "Type=Scalable",
                "Context=" + CONTEXT[ctx], ""]
    for ctx in LARGE:
        out += ["[%s/large]" % ctx, "Size=64", "MinSize=33", "MaxSize=512", "Type=Scalable",
                "Context=" + CONTEXT[ctx], ""]
    return "\n".join(out)


def run(tokens):
    vendor()
    made = []
    for theme in THEMES:
        name = "dot-os" + ("" if theme == "dark" else "-light")
        base = "packages/icon-theme/files/%s/" % name
        shutil.rmtree(os.path.join(ROOT, base), ignore_errors=True)
        colour = tokens[theme]["text-primary"]
        for ctx, names in MAP.items():
            for icon, lucide in names.items():
                made.append(write(base + "%s/scalable/%s.svg" % (ctx, icon), render(lucide, colour)))
                if ctx in LARGE:
                    made.append(write(base + "%s/large/%s.svg" % (ctx, icon), render(lucide, colour, "0.75")))
        made.append(write(base + "index.theme", index(theme)))
    return made
