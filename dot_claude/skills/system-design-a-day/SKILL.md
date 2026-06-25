---
name: system-design-a-day
description: Personal front-end system design practice system. Triggers on practice system design, teach system design, quiz system design, sync system design, front-end system design, RADIO framework, front-end interview prep.
user-invocable: false
---

Personal front-end system design practice skill. Scaffolds design problems
and concept tutorials in `~/system-design-a-day/`, tracks progress with spaced
repetition, and runs daily practice sessions at adjustable effort levels.
Designs are written as markdown design docs (no code executed). Modeled on
the GreatFrontend Front-End System Design Playbook and its RADIO framework.

For a walkthrough of commands, effort levels, and tips, see
`${CLAUDE_SKILL_DIR}/references/usage_guide.md`.

## Setup

Before anything else, ensure the practice repo exists:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/setup.py
```

Then read `~/system-design-a-day/learner_profile.md` if it exists. This
profile has the user's comfort level, goals, and preferences — use it to
calibrate difficulty, pacing, and explanations.

If no learner profile exists, do a brief onboarding (2 questions, one at a
time):

1. **Comfort level**: "How comfortable are you with front-end system design
   right now? (e.g., never done one, some reading/videos, done a few mocks,
   interview-ready)"
2. **Primary goal**: "What's driving this practice? (e.g., interview prep
   with a specific company/role, general architectural depth, prepping to
   lead FE design at work, etc.)"

Save responses to `~/system-design-a-day/learner_profile.md` with date
frontmatter.

**At the start of every practice session**, also read these references (they
shape everything you do):
- `${CLAUDE_SKILL_DIR}/references/radio_framework.md` — the 5 phases with
  timing
- `${CLAUDE_SKILL_DIR}/references/clarifying_questions.md` — the 8-question
  checklist used to grade phase R
- `${CLAUDE_SKILL_DIR}/references/common_mistakes.md` — the 6 pitfalls to
  watch for

For deep mode, additionally read `${CLAUDE_SKILL_DIR}/references/rubric.md`.

## Effort Levels

Effort is passed via `$ARGUMENTS` from commands. Parse the first word.

- **`quick`** (~20 min): drill one RADIO phase on a known problem OR a short
  quiz OR review.
- **`standard`** (~45 min): full RADIO walkthrough on a new problem. **This
  is the default** if no effort specified.
- **`deep`** (~90 min): full mock interview with strict phase timing and full
  6-axis rubric debrief.

## Practice Mode

Triggered by "practice" intent (e.g., `/practice-system-design`,
`/practice-system-design deep`).

All practice sessions use the **RADIO framework**: Requirements →
Architecture → Data model → Interface → Optimizations. The phases are
time-boxed (R <15%, A ~20%, D ~10%, I ~15%, O ~40%). Enforce the timing —
drifting past a phase is a graded failure mode, not a minor issue.

**Getting stuck is expected.** When the candidate freezes, normalize it, then
redirect them to the current RADIO phase's core question ("what would you
*ask* the interviewer right now?", "what are the components and who owns
what?"). Do not hand over design decisions — the point is practicing
recovery.

1. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type problems --format json` to survey existing work.
2. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/quiz_priority.py --type problems` to find review candidates.
3. **Decide**: new problem vs review, based on spaced repetition urgency and effort level.
   - If high-priority review items exist (priority > 2.0), do a review.
   - Otherwise, pick a new problem from `${CLAUDE_SKILL_DIR}/references/curriculum.md`.
   - **Progression logic**: start UI Components before Applications. Within each track, easy → medium → hard. A category is "comfortable" when ALL of:
     1. Average `understanding_score` ≥ 6 across its problems.
     2. No problem scores ≤ 3.
     3. At least one medium-difficulty problem at ≥ 5.
   - Hunter's front-end focus per his learner profile: prefer applications over classic backend-heavy prompts; use the curriculum as-is (it's already FE-focused).
4. **New problem flow**:
   a. Pick a problem from curriculum. Explain why (progression logic). Match difficulty to effort: a hard problem in quick mode is wrong.
   b. Scaffold: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_problem.py "News Feed" --type application --difficulty medium --topics "feeds,real-time,pagination"`
   c. Fill `problem.md`: write the **Prompt** (conversational — this is all the candidate sees in deep mode), the **Suggested constraints** (hidden until R extracts them), and the **Focus areas** (for your own deep-dive steering).
   d. Present the problem. Depth varies by effort:
      - **quick/standard**: include prompt + visible constraints so the candidate can skim quickly.
      - **deep**: conversational prompt only — no written constraints, no focus areas revealed. The candidate must extract all of it through phase R. This mirrors a live mock interview.
   e. **RADIO walkthrough** — guide through the 5 phases. Depth varies by effort:

      **quick**: pick ONE phase (e.g. "let's drill phase D on the News Feed data model"). One-liner recap of the other phases. Work at user's pace.

      **standard**: walk all 5 phases interactively. Enforce time-boxing. At each phase transition:
      - **Phase R (<15%, ~7 min of 45)**: ask the candidate what clarifying questions they want to ask. Answer from the Suggested constraints. Score their question coverage against the 8-question checklist — surface 1–2 important ones they missed before moving on. Before leaving R, have them restate the scope in their own words.
      - **Phase A (~20%, ~9 min)**: require a diagram. Accept ASCII or mermaid. Push for named component responsibilities. If they skip the diagram, send them back.
      - **Phase D (~10%, ~4 min)**: require a table with entity → fields → source → owner. Catch missing ephemeral UI state.
      - **Phase I (~15%, ~7 min)**: require at least 3 APIs with params + response shape. For UI-component problems, this is the component's public prop API.
      - **Phase O (~40%, ~18 min)**: this is the main event. Have them pick 2–4 axes explicitly; don't let them try to cover all. For each chosen axis, require 2–3 concrete techniques with rationale tied back to requirements.

      **deep**: full mock interview simulation. Enforce all the above PLUS:
      - No visible constraints — user extracts everything.
      - Interviewer-style pushback on weak answers. "Why that and not the alternative?" "How does that scale with 10x the users?" "What happens when the network drops mid-request?"
      - Explicit feedback at each phase transition using the rubric's axis descriptors.
      - **After solving**, full 6-axis rubric debrief using `rubric.md`. Score per axis (strong/developing/needs work). Close with one concrete thing to improve next session.

   f. User works on the design in `design.md` (pre-scaffolded with RADIO section headers).
   g. When done, update `problem.md` frontmatter: `status`, `last_practiced`, `understanding_score` (1–10), and for deep sessions, `rubric_scores` (per-axis).
   h. **Always add the reference answer** after solving (per user memory preference: never ask, always add). Write a canonical/common design into `reference.md`. Prefer the straightforward common approach over clever optimizations — match the user's "idiomatic means common" preference.

5. **Review flow**: re-present an existing problem. For standard/deep effort levels, have the candidate walk RADIO again from memory without looking at their saved `design.md`. Tests whether the pattern internalized.

6. **Hints**: normalize the struggle first ("this stall is exactly what interviewers expect — it's about how you recover"). Then anchor hints to the current RADIO phase:
   - **R hints**: "what would change if the users were on 2G? What would you ask to find out?"
   - **A hints**: nudge toward the standard component set (Server, View, Controller, Client Store). Ask what each owns.
   - **D hints**: "what data is server-originated vs. client-only?"
   - **I hints**: "what does the view need to render the first screen? What API call gives you that?"
   - **O hints**: "what's the single highest-risk axis for this product? If the interviewer could only watch you deep-dive on one, which would it be?"

7. **Pacing**: if the user signals flagging confidence (per feedback memory), immediately pivot to an easier problem or drop to quick mode. Don't push through a disintegrating session.

## Teach Mode

Triggered by "teach" intent (e.g., `/teach-system-design`, `/teach-system-design websockets`).

1. Read `${CLAUDE_SKILL_DIR}/references/curriculum.md` for the Concepts tier.
2. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type concepts --format json` to see what's been covered.
3. **Pick the concept**: if the user specified, use that. Otherwise pick the concept that unblocks the next problem they'll face, or the one they've been weakest on in recent problems.
4. Scaffold: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_concept.py "WebSockets vs. SSE vs. Long Polling" --concepts "network,real-time"`
5. **Write the tutorial** in `concept.md`:
   - Start with **Why it matters** — what design problem does this solve, and which RADIO phase?
   - Build mental models with diagrams, analogies, walkthroughs.
   - **Variants & tradeoffs**: name 2–3 alternatives with when-to-pick guidance.
   - **When it appears in RADIO**: which phase triggers this concept.
   - **Real-world examples**: cite specific products/companies.
   - **Interview pitfalls**: common shallow takes.
6. Fill `examples.md` with 2–3 worked examples showing the concept in action (context → design → why).
7. Fill `checklist.md` with the decision framework — when to reach for this, red/green flags, follow-up questions to expect.
8. Walk through the tutorial with the user. Append Q&A to `concept.md`.

## Quiz Mode

Triggered by "quiz" intent (e.g., `/quiz-system-design`, `/quiz-system-design websockets`).

1. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/quiz_priority.py --type all` to get the prioritized list.
2. If user specified a topic, filter to that topic. Otherwise pick by spaced repetition priority.
3. **Ask 1 question at a time.** Wait for the user's answer before asking the next.
4. Mix question types:
   - **Conceptual**: "When would you choose SSE over WebSockets?"
   - **Scenario**: "A Chat app must support 10M concurrent users — what changes about your WebSocket architecture from the 100k-user version?"
   - **Tradeoff drill**: "Name the alternative to [X] and explain when it'd win."
   - **Diagram recall**: "Sketch the data flow for optimistic message send in a chat app, including the failure path."
   - **Pitfall spotting**: "Here's a candidate answer for [Y] — what's weak about it?"
   - **API design**: "Design the pagination API for an infinite feed. Cursor vs. offset — which, and why?"
5. After the quiz (3–5 questions per session):
   - Score 1–10 based on demonstrated understanding (use `rubric.md`'s guidance; a 5 on a hard concept is more than a 5 on an easy one).
   - Update `understanding_score` and `last_quizzed` in the relevant `problem.md` or `concept.md`.
   - Append to `## Quiz History`:
     ```
     ### Quiz - DD-MM-YYYY
     **Q:** [Question asked]
     **A:** [Summary of response + what it revealed]
     Score updated: X → Y
     ```

### Scoring Guide

- **1–3**: Can't recall, needs re-teaching.
- **4–5**: Vague grasp, partial answers, misses the tradeoff.
- **6–7**: Solid understanding, minor gaps, can name the alternative.
- **8–9**: Strong grasp with edge cases and real-world examples.
- **10**: Could teach this.

Difficulty calibration applies — see `rubric.md`.

## Sync Mode

Triggered by "sync" intent (e.g., `/sync-system-design`).

1. `cd ~/system-design-a-day`
2. `git add -A && git commit -m "Practice session <date>"`
3. Check if remote exists: `git remote -v`
4. If no remote, offer to create: `gh repo create system-design-a-day --private --source=. --push`
5. If remote exists: `git push`

---

## Reference map

| File | When to load |
|------|-------------|
| `references/radio_framework.md` | Every practice session |
| `references/clarifying_questions.md` | Every practice session (guides phase R scoring) |
| `references/common_mistakes.md` | Every practice session (watch for these) |
| `references/rubric.md` | Deep-mode sessions (end-of-session debrief) |
| `references/curriculum.md` | When picking a new problem or concept |
| `references/usage_guide.md` | Reference for the user, not the skill |
