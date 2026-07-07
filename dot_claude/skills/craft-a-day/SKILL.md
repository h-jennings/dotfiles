---
name: craft-a-day
description: Personal programming-craft and fluency practice system — keeps everyday coding skills sharp through short daily reps. Triggers on craft a day, craft practice, craft session, refactor drill, build-from-scratch or breakable toy, TypeScript fluency, idiomatic JS/TS, type puzzle, testing-craft drill, debugging drill, async or concurrency practice, code kata, teach-craft, review-craft, sync-craft. Six tracks build, refactor, fluency, testing, debugging, async. NOT for interview prep — for algorithm/LeetCode practice use dsa-a-day instead, for architecture use system-design-a-day.
user-invocable: false
---

Personal craft-practice skill. Scaffolds small exercises and concept tutorials in
`~/craft-a-day/`, tracks them with light spaced repetition, and runs short
sessions to keep everyday coding craft fluent. Solutions are in TypeScript. For
commands, the craft loop, and tips, see `${CLAUDE_SKILL_DIR}/references/usage_guide.md`.

## Operating Mode — read first

This skill exists to keep the craft **alive and fluent** now that the user is
employed — protecting against atrophy and preserving the joy of building. It is a
deliberate counterpart to `dsa-a-day` and `system-design-a-day`, which stay as
explicit, untouched interview-prep resources.

Hold this posture:

- **Craft-native and low-ceremony.** No interview framework, no mock-interview
  role-play, no process rubric, no readiness bar. There is no roadmap to finish.
  Keep it that way — this skill must never accumulate interview-prep gravity.
- **Light and situational.** `quick` is the default. A short morning rep before
  work is the typical session. Celebrate clean code as much as a correct answer,
  and normalize getting stuck — struggle is the practice working.
- **Fresh mixed bag.** Rotate across the six tracks so sessions stay varied.
  Lean occasionally toward the rusty edge, not only the comfortable groove.
- **Apprenticeship mindset.** The skill is grounded in *Apprenticeship Patterns*
  — Breakable Toys, Practice Practice Practice, Reflect As You Work, Record What
  You Learn. Apply the ideas; don't lecture about them. See
  `${CLAUDE_SKILL_DIR}/references/apprenticeship_mindset.md`.

## Setup

Before anything else, ensure the practice repo exists:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/setup.py
```

Then read `~/craft-a-day/learner_profile.md` if it exists — it holds comfort
level, goals, and preferences; use it to calibrate.

If no profile exists, do a brief onboarding. The user is a known quantity (an
employed front-end engineer who works in TypeScript, values clarity/clean code,
and loves the *Apprenticeship Patterns* mindset), so **propose a pre-filled
profile** and confirm rather than interrogating. Ask at most:

1. **Focus areas**: "Any tracks or topics you most want to keep sharp — or any
   rusty edges to lean into?"
2. **Cadence**: "Roughly how long do you want a typical session to be?"

Save to `~/craft-a-day/learner_profile.md` with `created` / `last_updated` date
frontmatter and short markdown sections (Comfort, Goals, Preferences, Focus areas).

## Effort Levels

Effort comes from `$ARGUMENTS` (the first word). It may be an effort level, a
track name, or `review`. Parse accordingly; default effort is `quick`.

- **`quick`** (~15 min, default): one fluency drill, a small debugging or
  refactor rep. A warm-up.
- **`standard`** (~30 min): a build / testing / async exercise with the full craft loop.
- **`deep`** (~60 min): a larger breakable toy or multi-step build, optionally
  paired with a `teach-craft` concept first. Opt-in.

## The Six Tracks

A flat mixed bag (each exercise is tagged by `track` in frontmatter). Full
descriptions, when-to-reach-for-it, and seed exercise banks are in
`${CLAUDE_SKILL_DIR}/references/tracks.md` — read it before choosing an exercise.

- **build** — Breakable Toys: build a utility from scratch
- **refactor** — clean up smelly code / sharpen code-review judgment
- **fluency** — idiomatic JS/TS drills + TypeScript type puzzles
- **testing** — write thorough tests for given code (test design)
- **debugging** — diagnose & fix a planted bug
- **async** — promises, cancellation, race conditions, concurrency

## Practice Mode

Triggered by craft intent (e.g., `/craft`, `/craft quick`, `/craft refactor`).

1. Survey existing work: `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type all --format human`
2. Find review candidates: `python3 ${CLAUDE_SKILL_DIR}/scripts/review_priority.py --type all`
3. **Decide new vs. review:**
   - If a review item is clearly due (priority > ~2.0) and the user is up for it,
     offer a re-solve. Otherwise do a new exercise.
4. **Pick the track (keep it fresh):**
   - If `$ARGUMENTS` names a track, use it.
   - Else pick a track **different from the most recent exercise's** `track`
     (check the newest `created` date via the index). Bias gently toward the
     user's stated rusty edges / weak spots.
5. **Pick a concrete exercise** from the track's seed bank in `tracks.md` (or
   invent one — prefer ideas connected to the user's real front-end/TS work).
   Read `tracks.md` for that track's specific drill shape.
6. **Scaffold:**
   `python3 ${CLAUDE_SKILL_DIR}/scripts/create_exercise.py "Title" --track <track> --patterns "..." --topics "..."`
7. **Fill in the scaffold** — this is track-specific:
   - **build / async** — write the brief, requirements, and a stub signature in
     the starter; leave `it.todo` tests for the user (or sketch expected cases).
   - **fluency** — write the drills (value drills or `Expect<Equal>` type puzzles)
     in `drills.ts`; brief states the target.
   - **refactor** — write working-but-smelly code in `before.ts` AND green
     behavior-pinning tests in `before.test.ts`; brief names the goal/smells to
     hunt. (For a pure code-review rep, ask for the critique in `brief.md` instead.)
   - **testing** — write a CORRECT implementation in `subject.ts`; leave
     `subject.test.ts` for the user to fill; brief asks for thorough tests.
   - **debugging** — write code with ONE planted bug in `buggy.ts` AND a red test
     in `buggy.test.ts` that exposes it; brief frames the symptom, not the cause.
8. **Present** the exercise. For `quick`, keep it terse. Don't over-explain.
9. **Run the craft loop** with the user (lightly — this is not an interview):
   (1) read brief, (2) sketch approach + name the key tradeoff, (3) implement,
   (4) make it green / self-review, (5) reflect. Let them drive; offer hints only
   when asked, and normalize getting stuck first.
10. **Verify:** `cd ~/craft-a-day && pnpm vitest run exercises/<slug>` (or
    `pnpm typecheck` for type puzzles). See `references/toolchain.md`.
11. **After solving:**
    - **Always add the worked reference solution** as `solution.ts` (or a
      `## Reference solution` block in `brief.md`) — idiomatic and commented,
      something to study. (Standing user preference.)
    - Discuss tradeoffs / alternatives briefly.
    - Update `brief.md` frontmatter: `status`, `confidence` (1–5 self-check),
      `last_practiced`.
    - **Reflect:** append one honest line to the `## Reflection` block and to
      `~/craft-a-day/learnings.md` (format: `- DD-MM-YYYY [track] takeaway (slug)`).

**Re-solving a past exercise** is its own first-class mode — see **Review Mode** below.

## Teach Mode

Triggered by teach intent (e.g., `/craft teach`, `/craft teach discriminated-unions`).

1. Survey concepts: `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type concepts --format human`
2. Pick the next valuable concept (user's request, a rusty edge, or something a
   recent exercise touched).
3. Scaffold: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_concept.py "Title" --concepts "c1,c2"`
4. **Write the tutorial** in `concept.md`: start with *why*, build the mental
   model, name when to reach for it (and when not), show where it appears in
   real front-end/TS work. Reference the user's own past exercises when relevant.
5. **Fill `examples.ts`** with runnable code (`pnpm tsx concepts/<slug>/examples.ts`).
6. **Write `exercise.ts`** — a short practice exercise to cement it.
7. Walk through it, answer questions, append any Q&A to the `## Q&A` section.

## Review Mode

Triggered by review intent (e.g., `/craft review`, `/craft review async`).
Spaced repetition done **code-first**: instead of asking questions, resurface a
past exercise and have the user re-solve it hands-on. Getting reps in, not a viva.

1. Prioritize: `python3 ${CLAUDE_SKILL_DIR}/scripts/review_priority.py --type all`
   (filter to a track if one was named). Pick the most-due item.
2. **Reset it to a fresh rep — never show `solution.ts` until step 5.**
   - **exercise** — re-serve the original prompt. Re-present `brief.md`, and make
     the working file blank/stubbed again: the prompt files (`before.ts`,
     `buggy.ts`, `subject.ts`, or the `starter.ts` stub / `drills.ts`) were
     committed at scaffold time, so recover them with git if a past solution now
     sits there — e.g. `git log --oneline -- <path>` then
     `git checkout <scaffold-commit> -- <path>` (or just clear the file back to
     the stub shown in the brief). Confirm tests are red/pending before they start.
   - **concept** — turn it into a short code drill: re-serve the concept's
     `exercise.ts` (or invent a fresh 5-minute micro-drill on the same idea).
     Skip pure recall Q&A — make them *write* the thing.
3. **Let them solve it live**, lightly running the craft loop. Offer hints only
   when asked; normalize being rustier than last time — that's the signal working.
4. **Verify:** `cd ~/craft-a-day && pnpm vitest run exercises/<slug>` (or
   `pnpm typecheck` for type puzzles / drills).
5. **After the rep**, for the item reviewed:
   - Compare briefly against the reference solution — what came back fast, what
     was rusty. Keep it a conversation, not a grade.
   - Log a **confidence** self-check (1–5: shaky → fluent). A private scheduling
     signal, **not a grade** — no pass/fail, no pressure.
   - Update `confidence` and `last_reviewed` in the item's frontmatter.
   - Append to its `## Review History`:
     ```
     ### Review - DD-MM-YYYY
     **Re-solved:** [what they rebuilt/fixed]
     **Rusty on:** [what needed a second look — or "clean"]
     Confidence: X/5
     ```
   - Append one line to `~/craft-a-day/learnings.md` if the rep surfaced anything
     worth keeping (format: `- DD-MM-YYYY [track] takeaway (slug)`).

### Confidence scale (self-check, not a grade)
- **1** — shaky; would need to look it up
- **2** — vague; got there with hints
- **3** — solid with minor gaps
- **4** — comfortable; handles edge cases
- **5** — fluent; could teach it

## Sync Mode

Triggered by sync intent (e.g., `/craft sync`).

1. `cd ~/craft-a-day`
2. `git add -A && git commit -m "Craft session <date>"`
3. `git remote -v` — if no remote, offer `gh repo create craft-a-day --private --source=. --push`
4. If a remote exists: `git push`

---

## Reference Map

- `references/tracks.md` — the six tracks, when to use each, and seed exercise banks
- `references/apprenticeship_mindset.md` — the patterns behind the skill's posture
- `references/usage_guide.md` — commands, craft loop, effort levels, weekly rhythm
- `references/toolchain.md` — running TS/tests, type puzzles, async fake timers
