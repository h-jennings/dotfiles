# craft-a-day Usage Guide

Daily practice to keep your programming craft sharp and fluent — distinct from
interview prep. For algorithms reach for `dsa-a-day`; for architecture reach for
`system-design-a-day`. This skill is about the everyday craft of writing good
code.

## Commands

One command, `/craft`; the first word picks the mode (default: practice).

| Invocation | Mode | Time | What it does |
|------------|------|------|-------------|
| `/craft` | Practice (quick) | ~15 min | A short fluency drill or small rep — the default warm-up |
| `/craft standard` | Practice (standard) | ~30 min | A fresh exercise from a rotating track, worked with the craft loop |
| `/craft deep` | Practice (deep) | ~60 min | A meatier breakable toy or build, optionally with a concept first |
| `/craft <track>` | Practice | varies | Pin the track: `build` · `refactor` · `fluency` · `testing` · `debugging` · `async` |
| `/craft teach [topic]` | Teach | ~30 min | A concept tutorial with runnable examples + exercise |
| `/craft review [track]` | Review | ~15 min | Code-first spaced repetition — re-solve a past exercise hands-on |
| `/craft sync` | Sync | ~1 min | Git commit + push progress |

`/craft` sits alongside `/dsa` and `/sysd` (same first-word-is-the-mode shape) —
the command name is the skill, so there's never any overlap about what runs.

## The six tracks

A flat mixed bag, rotated to stay fresh (see `tracks.md` for full detail + seed banks):

- **build** — Breakable Toys: build a utility from scratch
- **refactor** — clean up smelly code / sharpen code-review judgment
- **fluency** — idiomatic JS/TS drills + TypeScript type puzzles
- **testing** — write thorough tests for given code (test design)
- **debugging** — diagnose & fix a planted bug
- **async** — promises, cancellation, race conditions, concurrency

## The craft loop

Lighter than an interview framework — the point is fluency, not ceremony:

1. **Read** the brief. Restate what "done" means in a sentence.
2. **Sketch** the approach and name the one key tradeoff or risk.
3. **Implement.**
4. **Make it green / self-review** — run the tests (or `typecheck` for type
   puzzles); read your own code as if reviewing a PR.
5. **Reflect** — one honest line: what was sharp, what was rusty. It goes in the
   exercise's `## Reflection` and in `learnings.md`.

## Effort levels

- **quick (~15 min)** — default. A fluency drill, a small debugging or refactor
  rep. Good before work.
- **standard (~30 min)** — a build/testing/async exercise with the full craft loop.
- **deep (~60 min)** — a larger breakable toy or multi-step build, optionally
  paired with a `teach-craft` concept. Opt-in.

## Suggested weekly rhythm

Loose on purpose — this is upkeep, not a program:

- **4–5x** `craft` / `craft quick` — rotate tracks for variety
- **1x** `craft review` — let spaced repetition resurface something to re-solve
- **occasionally** `craft teach` — when a concept deserves a real write-up
- `craft sync` after each session

## How tracking works

- **Confidence, not grades.** After a review you log a 1–5 *confidence* self-check
  (1 shaky → 5 fluent). It's a private signal for scheduling reviews, not a score
  to chase. No interview rubric, no pass/fail.
- **Gentle spaced repetition.** `review_priority.py` schedules reviews on a
  maintenance-paced ladder (roughly 2 / 5 / 14 / 30 / 60 days as confidence
  rises) — an occasional nudge, not a drill sergeant.
- **The logbook compounds.** `learnings.md` accumulates one line per session.
  Over months it's a record of how the craft grew. "Record What You Learn."

## Philosophy

This skill exists to keep the craft *alive* now that the user is employed — to
protect against atrophy and keep the joy of building. Keep sessions light and
rewarding, celebrate clean code, normalize getting stuck, and lean occasionally
toward the rusty edge rather than only the comfortable groove. See
`apprenticeship_mindset.md` for the patterns behind all of this.
