# dsa-a-day Usage Guide

How to get the most out of daily DSA practice with this skill.

## Commands

| Command | Mode | Time | What it does |
|---------|------|------|-------------|
| `practice` | Practice (standard) | ~30 min | New problem with interactive 6-step walkthrough |
| `practice quick` | Practice (quick) | ~15 min | Warm-up, review, or quick reps |
| `practice deep` | Practice (deep) | ~60 min | Full mock interview simulation with process feedback |
| `teach` or `teach <topic>` | Teach | ~30 min | Concept tutorial with runnable examples + exercise |
| `quiz` or `quiz <topic>` | Quiz | ~15 min | 3-5 question spaced repetition quiz |
| `sync` | Sync | ~1 min | Git commit + push progress |

## Suggested weekly rhythm

- **4-5x** `practice` (standard) — daily default
- **1-2x** `practice deep` — mock interview simulation
- **1x** `quiz` — spaced repetition review of weak spots
- **1x** `teach` — when hitting a new topic (stacks, sliding window, etc.)
- `sync` after each session

## The 6-step framework

Every practice session uses this framework. The goal is to make it automatic:

1. **Repeat** — Restate the problem in your own words. Catches misunderstandings early.
2. **Clarify** — Ask filtering questions (see the 7-question checklist in `clarifying_questions.md`). Each question eliminates or enables approaches.
3. **Examples** — Trace through at least one example by hand. Add an edge case.
4. **Brainstorm** — Name at least two approaches with complexity. Present tradeoffs. Ask which one to pursue.
5. **Implement** — Should be the fastest step if 1-4 were done well. If stuck, go back to examples.
6. **Test** — Trace through code with a concrete input before running tests. Predict the output.

## Effort levels explained

### Quick (~15 min)
- One-liner recap of the 6 steps, then work at your own pace
- Best for: warm-ups, re-solving review problems, staying sharp on short days

### Standard (~30 min)
- Interactive walkthrough of Steps 1-4 before coding
- Interviewer buy-in simulation (skill picks which approach to implement)
- Best for: daily practice, building the 6-step habit

### Deep (~60 min)
- Full mock interview simulation
- Problem presented verbally only — no examples or constraints given upfront
- Explicit feedback at each step (question quality, example coverage, approach articulation)
- Process Rubric debrief after solving (communication, question quality, struggle recovery, approach articulation, time awareness)
- Best for: interview readiness testing, 1-2x per week

## Tips

- **Don't rush past clarifying questions.** This is where you show you think before you code. The skill teaches a 7-question filtering checklist — internalize it.
- **When the skill gives you a preference** ("start with brute force"), go with it. This trains seeking and following interviewer direction.
- **When you're stuck, say so.** The skill normalizes struggle and redirects you to your examples or constraints rather than handing you the answer.
- **Review the process rubric feedback** after deep sessions. It tells you what to work on beyond "did I get the right answer."
- **Know your built-in Big O.** The skill quizzes on this. `.includes()` inside a loop = O(n^2). `Map.has()` = O(1). These matter in interviews.
- **Brute force is a skill too.** Sometimes the exercise is writing the naive O(n^2) solution correctly. A working brute force beats a blank whiteboard.

## How progress tracking works

- **Spaced repetition**: Problems and concepts have `understanding_score` and `last_quizzed` fields. The skill uses Fibonacci-style intervals to prioritize what to review.
- **Weak spot tracking**: Recurring struggle patterns are tracked in memory and used for targeted problem selection.
- **Curriculum progression**: Topics advance from Foundation → Core Patterns → Intermediate → Applied. A topic is "comfortable" when: average score >= 6, nothing scores <= 3, and at least one medium-difficulty problem completed with score >= 5. No minimum problem count — scores decide, not reps.
- **Difficulty escalation**: Within a topic, the skill starts you on easy problems, escalates to medium when easy scores average 7+, and to hard when medium scores average 7+. Hard problems aren't required to advance but deepen mastery.
- **Difficulty-calibrated scoring**: A score of 5 on a hard problem represents more competence than a 5 on an easy. Scores factor in what was reasonable given the difficulty.
