---
name: dsa-a-day
description: Personal DSA practice system. Triggers on practice DSA, teach DSA, quiz DSA, sync DSA, algorithm practice, data structure learning, front-end interview prep, daily coding problem.
---

Personal DSA practice skill. Scaffolds problems and concept tutorials in `~/dsa-a-day/`, tracks progress with spaced repetition, and runs daily practice sessions at adjustable effort levels. Solutions are in TypeScript.

## Setup

Before anything else, ensure the practice repo exists:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/setup.py
```

Then read `~/dsa-a-day/learner_profile.md` if it exists. This profile has the user's comfort level, goals, and preferences — use it to calibrate difficulty, pacing, and explanations.

If no learner profile exists, do a brief onboarding (2 questions, one at a time):

1. **Comfort level**: "How comfortable are you with DSA right now? (e.g., beginner, can solve easy LC, solid on mediums, etc.)"
2. **Primary goal**: "What's driving this practice? (e.g., interview prep, general sharpening, front-end depth, etc.)"

Save responses to `~/dsa-a-day/learner_profile.md` with date frontmatter.

## Effort Levels

Effort is passed via `$ARGUMENTS` from commands. Parse the first word.

- **`quick`** (~15 min): 1 easy/review problem OR a short quiz session
- **`standard`** (~30 min): 1 new problem with concept explanation. **This is the default** if no effort specified.
- **`deep`** (~60 min): Concept tutorial + problem + quiz

## Practice Mode

Triggered by "practice" intent (e.g., `/practice`, `/practice quick`).

1. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type problems --format json` to survey existing work
2. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/quiz_priority.py --type problems` to find review candidates
3. **Decide**: new problem vs review, based on spaced repetition urgency and effort level
   - If high-priority review items exist (priority > 2.0), do a review
   - Otherwise, pick a new topic from `${CLAUDE_SKILL_DIR}/references/curriculum.md`
   - For topic selection: check progression (what's been covered), identify weaknesses (low scores), and advance to the next tier when comfort threshold is met
4. **New problem flow**:
   a. Pick topic + specific problem. Explain why this problem was chosen (progression logic)
   b. Scaffold via: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_problem.py "Problem Title" --difficulty <easy|medium|hard> --topics "topic1,topic2"`
   c. Fill in the scaffolded files: write the problem description in `problem.md`, the function signature + types in `starter.ts`, and test cases in `solution.test.ts`
   d. Present the problem to the user with examples, constraints, and expected complexity
   e. User works on the solution — they can edit `starter.ts` directly or create `solution.ts`
   f. When ready, run tests: `cd ~/dsa-a-day && pnpm vitest run problems/<slug>/solution.test.ts`
   g. After solving: discuss complexity, review approach, suggest optimizations
   h. Update `problem.md` frontmatter: set `status`, `time_complexity`, `space_complexity`, `last_practiced`
5. **Review flow**: Re-present an existing problem, have user re-solve or explain approach, then quiz
6. **Hints**: If user asks for help, give hints progressively — nudge toward the pattern first, then the key insight, then pseudocode. Don't jump to the solution.

## Teach Mode

Triggered by "teach" intent (e.g., `/teach-dsa`, `/teach-dsa hash-maps`).

1. Read `${CLAUDE_SKILL_DIR}/references/curriculum.md` for the topic taxonomy and progression
2. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type concepts --format json` to see what's been covered
3. **Identify next valuable concept**: Consider what the user is weak on (low quiz scores), what problems they've done (related concepts), and what naturally follows from their current tier in the curriculum. If user specified a topic, use that.
4. Scaffold: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_concept.py "Concept Title" --concepts "concept1,concept2"`
5. **Write the tutorial** in `concept.md`:
   - Start with "why" — what problem does this solve?
   - Build mental models with diagrams, analogies, step-by-step walkthroughs
   - Reference the user's own past solutions as examples when possible
   - DSA-specific: when to use this structure, complexity tradeoffs, real front-end use cases
6. **Fill in `examples.ts`** with runnable code demonstrating the concept. The user should be able to run `cd ~/dsa-a-day && pnpm tsx concepts/<slug>/examples.ts` and see it in action.
7. **Write `exercise.ts`** — a practice exercise the user completes to cement understanding
8. Walk the user through the tutorial. Answer questions. Append any Q&A to the `## Q&A` section in `concept.md`.

## Quiz Mode

Triggered by "quiz" intent (e.g., `/quiz-dsa`, `/quiz-dsa arrays`).

1. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/quiz_priority.py --type all` to get prioritized list
2. If user specified a topic, filter to that topic. Otherwise, pick based on spaced repetition priority.
3. **Ask 1 question at a time.** Wait for the user's answer before asking the next.
4. Mix question types:
   - Conceptual: "When would you use X over Y?"
   - Code reading: "What does this function return for input [...]?"
   - Code writing: "Write a function that..."
   - Complexity analysis: "What's the time complexity of...?"
   - Decision: "You need to do X in a React component — which data structure?"
5. After the quiz (3-5 questions per session):
   - Score 1-10 based on demonstrated understanding
   - Update `understanding_score` and `last_quizzed` in the frontmatter of the relevant `problem.md` or `concept.md`
   - Append to `## Quiz History` section:
     ```
     ### Quiz - DD-MM-YYYY
     **Q:** [Question asked]
     **A:** [Summary of response + what it revealed]
     Score updated: X → Y
     ```

### Scoring Guide
- **1-3**: Can't recall, needs re-teaching
- **4-5**: Vague memory, partial answers
- **6-7**: Solid understanding, minor gaps
- **8-9**: Strong grasp, handles edge cases
- **10**: Could teach this to someone else

## Sync Mode

Triggered by "sync" intent (e.g., `/sync-dsa`).

1. `cd ~/dsa-a-day`
2. `git add -A && git commit -m "Practice session <date>"`
3. Check if remote exists: `git remote -v`
4. If no remote, offer to create: `gh repo create dsa-a-day --private --source=. --push`
5. If remote exists: `git push`
