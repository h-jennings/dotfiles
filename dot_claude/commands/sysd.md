---
description: System Design A Day — front-end system design practice. First word picks the mode (default practice).
argument-hint: "[teach|quiz|sync] | [quick|standard|deep] [topic]"
---

Use the **system-design-a-day** skill. Route by the first word of "$ARGUMENTS":

- `teach` → **Teach mode** (remaining words = the topic)
- `quiz`  → **Quiz mode** (remaining words = a topic filter)
- `sync`  → **Sync mode**
- anything else, or empty → **Practice mode**, treating the args as the effort
  level (`quick`/`standard`/`deep`) and/or a topic

Then follow that mode's workflow in the skill's SKILL.md.
