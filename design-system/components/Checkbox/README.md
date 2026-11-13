A checkbox is one independent yes-or-no choice inside a form, applied when the form is confirmed.

**You provide:** the label text to its right, and the checked state.

- Class `dot-check` on an `input type="checkbox"`, wrapped with its text in a `label.dot-opt`.
- The mark is a filled `text-display` block inside the outline, not a tick. Off is a 1px `text-secondary` outline, which keeps 3:1 against `black` and `surface`.
- `radius-technical` corners, 18px box, `control-min` row height.
- For a setting that applies the moment it changes, use a Toggle instead.
- Disabled drops to 40% opacity and its label to `text-disabled`.
