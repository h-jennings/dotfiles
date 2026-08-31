---
description: Voice Brief — hear a spoken brief on a diff, file, or branch while you read it.
argument-hint: "[review|explain|digest] [target] (e.g. review the current diff)"
---

Use the **voice-brief** skill. Route by the first word of "$ARGUMENTS":

- `review` → **Review mode** (remaining words = the diff, PR, or branch)
- `explain` (or `teach`) → **Explain mode** (remaining words = the file or concept)
- `digest` (or `catchup`) → **Digest mode** (remaining words = the branch, PR queue, or session)
- anything else, or empty → infer the mode from the target; ask only if genuinely ambiguous

If the args mention a dialogue, discussion, or two voices, use dialogue mode.

Then follow that mode's workflow in the skill's SKILL.md, and always show the
script for approval before generating audio.
