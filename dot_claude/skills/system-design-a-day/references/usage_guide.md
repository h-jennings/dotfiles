# system-design-a-day Usage Guide

How to get the most out of daily front-end system design practice.

## Commands

| Command | Mode | Time | What it does |
|---------|------|------|-------------|
| `practice system design` | Practice (standard) | ~45 min | New problem with full RADIO walkthrough |
| `practice system design quick` | Practice (quick) | ~20 min | Drill one RADIO phase on a known problem, or review |
| `practice system design deep` | Practice (deep) | ~90 min | Full mock interview with rubric debrief |
| `teach system design [topic]` | Teach | ~30 min | Concept tutorial with worked examples + checklist |
| `quiz system design [topic]` | Quiz | ~15 min | 3–5 question spaced repetition quiz |
| `sync system design` | Sync | ~1 min | Git commit + push progress |

## Suggested weekly rhythm

- **3–4x** `practice` (standard) — daily default
- **1x** `practice deep` — mock interview simulation
- **1x** `quiz` — spaced repetition review of weak spots
- **1x** `teach` — when hitting a new concept (WebSocket, CRDT, SSR, etc.)
- `sync` after each session

## The RADIO framework

Every practice session follows RADIO:

1. **R**equirements exploration (<15%) — clarify scope, narrow the problem
2. **A**rchitecture / high-level design (~20%) — components + data flow
3. **D**ata model (~10%) — entities, fields, ownership
4. **I**nterface definition (~15%) — APIs with params and responses
5. **O**ptimizations and deep dive (~40%) — the grade is earned here

Full reference: `radio_framework.md`.

## Effort levels explained

### Quick (~20 min)
- Pick one RADIO phase of an already-seen problem and drill it. Or quiz.
- Best for: spaced repetition, short days, single-axis drilling.

### Standard (~45 min)
- Full RADIO walkthrough on a new problem.
- Interviewer (Claude) enforces time-boxing and gives feedback at each phase transition.
- Best for: daily practice, building the RADIO habit.

### Deep (~90 min)
- Full mock interview.
- Problem is presented *conversationally* — constraints are not written out; user must extract them in phase R.
- Strict phase timing; interviewer pushes back on weak answers.
- Ends with full 6-axis rubric debrief from `rubric.md` + one concrete thing to improve.
- Best for: interview readiness testing, 1x per week.

## Tips

- **Always announce your phase.** "OK, moving into phase A." This is half the structure grade.
- **Ask before designing.** Minimum 3 clarifying questions in phase R. Missing one that matters is a graded miss in deep mode.
- **Draw the diagram.** Phase A without a diagram is a failed phase A. ASCII or mermaid is fine.
- **Name the alternative.** For every major decision, say what you didn't pick and why.
- **Don't try to cover all of phase O.** Pick 2–4 axes that matter most for *this* product.
- **Never drop a buzzword without explanation.** If you invoke "virtual DOM," be ready to explain reconciliation in one sentence.

## How progress tracking works

- **Spaced repetition**: problems and concepts have `understanding_score` and `last_quizzed` fields. The skill uses Fibonacci-style intervals (1, 2, 3, 5, 8, 13, ...) to prioritize reviews.
- **Per-axis rubric scores**: deep sessions record strong/developing/needs-work per axis in `rubric_scores`. Surfaces which skills to drill vs. which problems to re-run.
- **Curriculum progression**: UI Components → Applications. Each track has easy → medium → hard. A problem category is "comfortable" when average understanding_score ≥ 6, no score ≤ 3, and at least one medium-difficulty problem completed at 5+.
- **Difficulty calibration**: a 5 on a hard problem represents more competence than a 5 on an easy. Scores factor in what was reasonable given difficulty.
