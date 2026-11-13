A notification is a flat card stacked under the top bar's right edge. It states one fact and offers at most two actions.

**You provide:** the source app (a label), a time, a title of five words or fewer, one sentence of body, and up to two actions.

- Classes `nil-note`, `nil-note__head`, `nil-note__title`, `nil-note__body`, `nil-note__actions`; add `nil-note--critical` for urgent ones.
- Title in `text-display`, body in `text-secondary`, source and time in `label`. No app icon, no avatar, no close button — it fades after 6 seconds or on click.
- Critical notifications get a 6px `accent` dot before the source label. That is the only difference; never a red background or border.
- Actions are ghost buttons; the affirmative one is `text-display`.
- For confirmations of something the user just did, do not notify: write inline status text (`[SAVED]`) next to the control instead.
- Stack with `space-sm` between cards, newest on top, three visible at most.
