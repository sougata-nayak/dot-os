# Linux surfaces

How the tokens map onto the parts of a distro that are themed outside the browser. Values are the dark theme; swap each for its light value to build the light variant.

## Fonts

Package Doto, Space Grotesk and Space Mono (all SIL OFL, from Google Fonts) and set them system-wide:

| Setting | Value |
|---|---|
| Interface font | Space Grotesk Regular, 11pt |
| Document font | Space Grotesk Regular, 11pt |
| Monospace font | Space Mono Regular, 11pt |
| Window title font | Space Mono Regular, 9pt, uppercase where the toolkit allows |

Doto is for the lock screen clock, the boot splash and the login greeter only.

## GTK 4 / libadwaita

Override the named colours in `~/.config/gtk-4.0/gtk.css` (or the distro's theme package). The system accent is **not** red: selection and focus invert to `text-display`, and `accent` is reserved for destructive and error roles.

```css
@define-color window_bg_color #000000;        /* black */
@define-color window_fg_color #E8E8E8;        /* text-primary */
@define-color view_bg_color #000000;          /* black */
@define-color view_fg_color #E8E8E8;          /* text-primary */
@define-color headerbar_bg_color #111111;     /* surface */
@define-color headerbar_fg_color #E8E8E8;     /* text-primary */
@define-color headerbar_border_color #222222; /* border */
@define-color sidebar_bg_color #000000;       /* black */
@define-color card_bg_color #111111;          /* surface */
@define-color card_fg_color #E8E8E8;          /* text-primary */
@define-color popover_bg_color #1A1A1A;       /* surface-raised */
@define-color popover_fg_color #E8E8E8;       /* text-primary */
@define-color dialog_bg_color #111111;        /* surface */
@define-color accent_bg_color #FFFFFF;        /* text-display */
@define-color accent_fg_color #000000;        /* black */
@define-color accent_color #FFFFFF;           /* text-display */
@define-color destructive_bg_color #D71921;   /* accent */
@define-color destructive_fg_color #FFFFFF;
@define-color destructive_color #D71921;      /* accent */
@define-color error_color #D71921;            /* accent */
/* entry, textview text { caret-color: #D71921; }  the caret is a live marker */
@define-color success_color #4A9E5C;          /* success */
@define-color warning_color #D4A843;          /* warning */

window, popover > contents, .card { box-shadow: none; }
window.csd { border: 1px solid #333333; border-radius: 12px; } /* border-visible, radius-card */
button { border-radius: 999px; }                               /* radius-pill */
```

## Qt / KDE Plasma

In a `.colors` scheme: `Colors:Window` and `Colors:View` background `black`, foreground `text-primary`; `Colors:Button` background `surface`; `Colors:Selection` background `text-display`, foreground `black`; `ForegroundNegative` `accent`, `ForegroundPositive` `success`, `ForegroundNeutral` `warning`, `ForegroundLink` `interactive`, `ForegroundInactive` `text-secondary`. Turn off window shadows, blur and translucency in the compositor. Qt widgets (Kvantum) use a 36px control height; `control-min` (44px) applies to the shell, greeter and installer. Window decorations: 1px `border-visible` outline, `titlebar-height`, `radius-card`.

## Tiling compositors (Hyprland, Sway, i3)

| Setting | Value |
|---|---|
| Gaps (inner / outer) | `space-sm` / `space-md` |
| Border width | 1px |
| Active border | `text-display` |
| Inactive border | `border-visible` |
| Urgent border | `accent` |
| Rounding | `radius-card` |
| Shadows, blur, dim | off |
| Animations | fade only, 200ms, `cubic-bezier(0.25, 0.1, 0.25, 1)` |
| Bar | `bar-height`, `black` background, 1px `border` bottom edge — see Top bar |

## Terminal palette

Background `black`, foreground `text-primary`, cursor `accent` (block, no blink — the caret is a live marker), selection `text-display` on `black` inverted.

| Slot | Normal (0–7) | Bright (8–15) |
|---|---|---|
| Black | `surface` #111111 | `text-disabled` #666666 |
| Red | `ansi-red` #D71921 | `ansi-red` #D71921 |
| Green | `ansi-green` #4A9E5C | `ansi-green` #4A9E5C |
| Yellow | `ansi-yellow` #D4A843 | `ansi-yellow` #D4A843 |
| Blue | `ansi-blue` #5B9BF6 | `ansi-blue` #5B9BF6 |
| Magenta | `ansi-magenta` #B07CC6 | `ansi-magenta` #B07CC6 |
| Cyan | `ansi-cyan` #5FB3B3 | `ansi-cyan` #5FB3B3 |
| White | `text-primary` #E8E8E8 | `text-display` #FFFFFF |

Bright and normal hues are the same on purpose: emphasis in the terminal comes from bold weight, not a second palette. Shell prompt: `user@host ~ >` in `text-secondary`, no powerline glyphs, no colour unless the last command failed — then the `>` turns `ansi-red`.

## Boot, login, lock

- **GRUB / systemd-boot:** `black` background, entries in Space Mono `text-secondary`, the selected entry in `text-display` wrapped in brackets: `[ DOT OS ]`. No background image.
- **Plymouth:** the wordmark in Doto, centred low-left, with a 20-segment progress bar and a Space Mono percentage beneath. The leading segment is `accent`. Messages as `[ OK ]` lines.
- **Session splash:** the same wordmark in the same position, over a 6-segment bar, one segment per start-up stage.
- **Greeter and lock screen:** see the Lock screen component. Clock in `display-xl` or larger, top-left; password field bottom-left; `nil-dot-grid` behind at full `border-visible`.

## Cursor, icons, wallpaper, sound

- **Cursor:** a plain arrow, `text-display` fill with a 1px `black` outline (inverted in light). No shadow, no animation except a segmented busy indicator.
- **Icon theme:** a monoline set at 1.5px stroke (Lucide or Phosphor Thin recoloured to `text-primary`). App icons sit in 44px outline circles in the dock; never full-colour vendor icons in the shell.
- **Wallpaper:** solid `black`, or `black` with the dot grid at `dot-pitch`. Nothing photographic.
- **Sound:** short, dry, mechanical — a click (2.4 kHz, 6 ms decay) and a tick (1.2 kHz, 20 ms decay). No chimes, no reverb, nothing longer than 400 ms. Files follow the freedesktop sound naming spec.
