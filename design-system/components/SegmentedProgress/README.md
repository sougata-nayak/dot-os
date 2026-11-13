The segmented bar is the system's signature readout: discrete square blocks, like an LED meter. Use it for progress, capacity, volume and brightness.

**You provide:** a label, the numeric reading, the number of segments (20 or 32) and how many are filled.

- Classes `nil-meter`, `nil-meter__head`, `nil-seg` holding one `<i>` per segment, `class="on"` for filled.
- Sizes: `nil-seg--hero` 16px (one per screen), default 10px, `nil-seg--compact` 4px.
- Filled segments are `text-display`; empty are `border`. Add `nil-seg--good`, `--warn` or `--bad` only when the value is a status.
- Always pair the bar with its number, and when it carries a status, with a word ("nearly full"). The bar is the proportion; the text is the meaning.
- Segments are square with 2px gaps. Never round them, never animate a sweep; fill one block at a time.
