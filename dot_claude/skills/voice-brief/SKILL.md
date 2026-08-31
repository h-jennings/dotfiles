---
name: voice-brief
description: Turn code review findings, explanations, or a catch-up digest into a spoken brief you listen to while you read the code yourself. Use when the user asks to hear, listen to, narrate, read aloud, brief me on, or "talk me through" a diff, PR, file, concept, branch, or agent session — or asks for TTS, voiceover, or audio of something. Writes a script built for the ear, then generates and plays it with the ElevenLabs CLI.
---

# Voice Brief

Voice is a second channel, not a substitute for the first. The point is **listen while reading**: the audio carries the argument — what changed, why it matters, what to watch for — while the user's eyes stay on the actual code. That division of labor decides everything about how the script is written.

So the deliverable is a *script*, not a summary read aloud. A bulleted review dump piped into TTS is unlistenable. Writing for the ear is the whole job; the script that generates the audio is plumbing.

## Non-negotiables

1. **Never speak code.** No identifiers spelled out, no syntax, no file paths, no line numbers read as digits. The user is looking at the code. Say "the early return in the cache lookup," not `if (!cache.has(key)) return`.
2. **Always show the script before generating.** The user reads it, corrects it, then approves. Generation costs credits and 90 seconds of their attention — both wasted on a script they'd have edited.
3. **Never open with preamble.** No "In this brief we'll cover." First sentence carries information.
4. **Keep it under three minutes** unless asked otherwise. ~150 words per minute; 400 words is a long brief. If the material won't fit, cut scope rather than talk faster.
5. **Report the file path** after generating, so the user can replay it.

## Workflow

### 1. Establish what they're looking at

Ask or infer: which diff, PR, file, branch, or session. The brief is written *against* something the user has open. If you don't know what's on their screen, the script can't reference it, and you'll fall back to reading a summary aloud — the failure mode this skill exists to avoid.

### 2. Do the real work first

The audio is the last step, never the first. Actually read the diff, run the review, understand the file. A spoken brief over a shallow reading is worse than silence — errors are harder to catch by ear, and the confident delivery hides them.

### 3. Write the script

Pick the mode below, then follow `references/writing-for-the-ear.md` for the sentence-level craft. Write it to a file in the scratchpad so it can be edited and regenerated without retyping.

### 4. Show it, get approval, generate

```bash
scripts/speak.py --file brief.txt --title "auth-refactor-review"
```

The audio plays immediately (detached) and the path is printed. Report the path and duration.

## The three modes

### Review — "walk me through this diff"

The user is scrolling the diff while listening. Structure:

- **Verdict first.** One sentence: is this sound, and what's the one thing that isn't. Never make them wait for it.
- **The shape of the change.** What the diff is actually doing, in the author's terms — not a file-by-file tour. "This moves session validation out of the middleware and into the route handlers" beats three minutes of per-file narration.
- **Findings, worst first**, each anchored to something visible: "in the retry helper," "the second of the two new hooks." Say the concern, the concrete failure, and how confident you are. Uncertainty must be audible — "I think" and "this is definitely wrong" sound different, and the ear trusts whatever it hears.
- **What you didn't check.** One line. The listener can't see the boundary of your review the way they'd see it in a written comment.

### Explain — "help me understand this"

The user is learning, with the file or concept in front of them. Structure:

- **The one-sentence version** of what this thing is and why it exists.
- **The problem it solves**, before any mechanism. Mechanism without motivation doesn't stick by ear.
- **The mechanism**, in the order someone would rediscover it — not in the order the code is laid out on screen.
- **Where it gets confusing**, named explicitly. The parts that trip people up are exactly what the listener needs flagged.
- **One thing to go look at** when the audio ends.

Repetition is a feature here, not padding. A listener can't scroll back — restating the key idea in different words once or twice is how it lands.

### Digest — "what happened while I was away"

Branch commits, the PR queue, or a long agent session the user didn't watch. Structure:

- **The headline.** What is different now than when they left.
- **Grouped by theme, not chronology.** Commit order is noise; "three commits tightening the upload path" is signal.
- **What needs them.** Decisions pending, things that broke, anything blocked on a human. End here — it's what they'll act on.

Skip anything mechanical. Dependency bumps and formatting commits don't earn airtime.

## Dialogue mode (opt-in)

For genuinely two-sided material — a design tradeoff, a "why not just X" question, competing approaches — a two-voice script can land better than a monologue, because disagreement is easier to follow when it has two voices attached.

Write it as `Name: line` per turn, then:

```bash
scripts/speak.py --file discussion.txt --dialogue --title "cache-invalidation-tradeoff"
```

Use it when the material has real tension. A dialogue where one voice exists to say "interesting, tell me more" is worse than a monologue — that's podcast cosplay, and it doubles the runtime for nothing.

## Script reference

`scripts/speak.py` reads from `--text`, `--file`, or stdin.

| Flag | Effect |
|---|---|
| `--voice NAME\|ID` | Voice name (fuzzy-matched, cached) or raw id |
| `--speed N` | 0.7–1.2 |
| `--title SLUG` | Names the output file — always pass it |
| `--out PATH` | Somewhere other than the cache dir |
| `--dialogue` | Input is a `Name: line` two-voice script |
| `--no-play` / `--wait` | Don't play / block until playback ends |
| `--dry-run` | Voice, chunk count, estimated duration — no API call |
| `--list-voices [Q]` | Available voices |

Long scripts are split on paragraph and sentence boundaries, generated with continuity context, and joined with ffmpeg — so length is not a reason to trim.

Defaults come from `~/.config/claude/voice-brief.json` (or `$VOICE_BRIEF_CONFIG`); `--help` prints its shape. Keep voice ids and personal defaults there, never in this skill.

Requires the ElevenLabs CLI authenticated once with `elevenlabs auth login`.

## Estimate before generating

`--dry-run` prints the word count and estimated duration. If a brief comes back at four minutes, cut it before spending the credits — and before spending the user's four minutes.
