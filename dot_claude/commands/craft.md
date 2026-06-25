---
description: Craft A Day — daily programming-craft practice. First word picks the mode (default practice).
argument-hint: "[teach|quiz|sync] | [quick|standard|deep] [track]"
---

Use the **craft-a-day** skill. Route by the first word of "$ARGUMENTS":

- `teach` → **Teach mode** (remaining words = the concept/topic)
- `quiz`  → **Quiz mode** (remaining words = a track filter)
- `sync`  → **Sync mode**
- `review` → Practice mode, review flow
- anything else, or empty → **Practice mode**, treating the args as the effort
  level (`quick`/`standard`/`deep`) and/or a track (`build`, `refactor`,
  `fluency`, `testing`, `debugging`, `async`)

Then follow that mode's workflow in the skill's SKILL.md.
