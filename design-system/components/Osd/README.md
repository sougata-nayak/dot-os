The on-screen display confirms a hardware key: volume, brightness, keyboard layout.

**You provide:** a three-letter `label`, the level as segments, and the number.

- Class `dot-osd`: a `surface` pill with a 1px `border-visible` outline, `control-min` tall, centred low on the screen.
- It fades in, holds for 1.5 seconds after the last key press, and fades out. It never takes focus.
- Muted shows the segments empty and the value as `[MUTED]`; it does not turn red.
