A select picks one value from a list too long for radios: a resolution, a disk, a language.

**You provide:** a `label` above it, the options, and the current one.

- Class `dot-select` on a `button`; the open list is a Menu (`dot-menu`) directly beneath it, the same width.
- Full 1px `border-visible` outline, `radius-compact`, value in Space Mono, a 16px chevron at the right in `text-secondary`.
- Hover and open brighten the outline to `text-primary`. The current option in the list inverts.
- The value never truncates in the middle; let the control grow or shorten the option text.
