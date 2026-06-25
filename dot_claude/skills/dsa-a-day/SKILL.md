---
name: dsa-a-day
description: Personal DSA practice system. Triggers on practice DSA, teach DSA, quiz DSA, sync DSA, algorithm practice, data structure learning, front-end interview prep, daily coding problem.
user-invocable: false
---

Personal DSA practice skill. Scaffolds problems and concept tutorials in `~/dsa-a-day/`, tracks progress with spaced repetition, and runs daily practice sessions at adjustable effort levels. Solutions are in TypeScript. For a walkthrough of commands, effort levels, and tips, see `${CLAUDE_SKILL_DIR}/references/usage_guide.md`.

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

All practice problems use the **6-step problem-solving framework**: (1) Repeat the question, (2) Ask clarifying questions, (3) Work through examples, (4) Brainstorm multiple solutions, (5) Implement, (6) Test. The goal is to build repeatable interview-style habits, not just coding ability. Step 4e below defines how to guide the user through these steps at each effort level.

**Getting stuck is expected and valuable.** In a real interview, the interviewer *wants* to see how you recover from being stuck — it's the primary signal they're evaluating, not whether you already know the answer. Going blank for a moment is fine. What matters is what you do next: talk through your thinking, revisit your examples, re-read the constraints, reach for your tools. Frame struggle as practice, not failure. Never rush past it.

1. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/index_content.py --type problems --format json` to survey existing work
2. Run `python3 ${CLAUDE_SKILL_DIR}/scripts/quiz_priority.py --type problems` to find review candidates
3. **Decide**: new problem vs review, based on spaced repetition urgency and effort level
   - If high-priority review items exist (priority > 2.0), do a review
   - Otherwise, pick a new topic from `${CLAUDE_SKILL_DIR}/references/curriculum.md`
   - For topic selection: check progression (what's been covered), identify weaknesses (low scores), and advance to the next tier when **comfort threshold** is met. A topic is "comfortable" when ALL of these are true:
     1. **Average score >= 6**: Mean `understanding_score` across the topic's problems is 6+ (solid understanding)
     2. **No critical gaps**: No problem in the topic scores <= 3 (nothing still in "can't recall" territory)
     3. **Medium-level competence**: At least one medium-difficulty problem completed with score >= 5. Easy-only cannot clear a topic.
   - There is no minimum or maximum problem count. If it takes 3 problems to get there, move on. If it takes 30, keep drilling. The scores are what matter, not the rep count.
4. **New problem flow**:
   a. Pick topic + specific problem. Explain why this problem was chosen (progression logic). **Difficulty escalation within a topic:**
      - Start with **easy** problems when entering a new topic — build base pattern recognition
      - Escalate to **medium** when easy scores in the topic average 7+ — the pattern is solid, now apply it with twists
      - Escalate to **hard** when medium scores average 7+ — for deep sessions and interview-hardening
      - Hard problems are not required to advance to a new topic, but they deepen mastery and prepare for real interview pressure
   b. Scaffold via: `python3 ${CLAUDE_SKILL_DIR}/scripts/create_problem.py "Problem Title" --difficulty <easy|medium|hard> --topics "topic1,topic2"`
   c. Fill in the scaffolded files: write the problem description in `problem.md`, the function signature + types in `starter.ts`, and test cases in `solution.test.ts`
   d. Present the problem to the user. Presentation depth varies by effort level:
      - **quick/standard**: Include examples, constraints, and expected complexity.
      - **deep**: Give only a conversational description of the problem — no examples, no explicit constraints, no target complexity. The user must extract these through clarifying questions in Step 2. This simulates a real interview where the interviewer describes the problem verbally and expects the candidate to ask for details. (The scaffolded files still contain the full problem for test purposes.)
   e. **6-step framework** — guide the user through the steps before and during coding. Depth depends on effort level:

      **quick**: Remind the user of the 6 steps (one-liner recap). Let them work at their own pace.

      **standard**: Walk through steps 1–4 interactively before coding. Steps 5–6 happen naturally during coding/testing (f–g below).
        - **Step 1 (Repeat):** Ask the user to restate the problem in their own words. Confirm or correct their understanding.
        - **Step 2 (Clarify):** Prompt for clarifying questions. Teach the user to treat each question as a **filter that narrows the solution space** — not just information gathering. Each answer should eliminate or enable entire categories of approaches (e.g., "Is it sorted?" → binary search is on the table, sorting algorithms are off). Use the **Clarifying Questions Checklist** (see reference section at the bottom) to evaluate what they asked and surface anything important they missed.
        - **Step 3 (Examples):** Have the user trace through at least one example by hand. Encourage adding an edge case (empty input, single element, negatives).
        - **Step 4 (Brainstorm):** Ask for at least two approaches with time/space complexity. If only brute force, discuss the space-time tradeoff: what redundant work could a data structure (hash map, stack, heap, etc.) eliminate? **Then simulate interviewer buy-in**: respond with a preference ("I'd like to see you implement approach B" or "Start with the brute force, then we'll optimize") rather than always letting the user choose freely. This teaches the habit of presenting options and seeking direction — a key interview skill Mays emphasizes.

      **deep**: Full mock interview simulation. Enforce all 6 steps sequentially:
        - Steps 1–4 as in standard, but give explicit feedback at each stage. Examples:
          - Step 1: "Good restatement — you missed one constraint."
          - Step 2: "You asked about sorting — good, that eliminates a whole class of solutions. But you didn't ask about input validity or what 'optimal' means here." Score their question coverage against the Clarifying Questions Checklist.
          - Step 3: "Your example didn't cover the empty-input case."
          - Step 4: "You jumped to the optimal approach — can you also describe the brute force and explain the tradeoff?"
        - **Step 5 (Implement):** If the user gets stuck, redirect them to their examples from Step 3 rather than giving algorithmic hints. Should be the fastest step if 1–4 were done well.
        - **Step 6 (Test):** Have the user trace through their code line by line with a concrete input before running tests. Ask them to predict the output. Track variable values. Check edge cases.
        - After completing: give overall feedback on their process, not just their solution.

   f. User works on the solution — they can edit `starter.ts` directly or create `solution.ts`
   g. When ready, run tests: `cd ~/dsa-a-day && pnpm vitest run problems/<slug>/solution.test.ts`
   h. After solving: discuss complexity, review approach, suggest optimizations. For **deep** sessions, also debrief using the **Process Rubric**:
      - **Communication**: Did the user think aloud consistently? Were they clear about their reasoning, or did they go silent for long stretches?
      - **Question quality**: Did they ask filtering questions (see Checklist below) that narrowed the solution space? Or did they jump straight to coding?
      - **Struggle recovery**: When stuck, did they go back to examples and constraints? Or freeze and wait for hints?
      - **Approach articulation**: Did they present multiple approaches with tradeoffs? Did they ask which one to pursue?
      - **Time awareness**: Did they spend proportionate time on each step, or get bogged down in one area?
      Score each dimension briefly (strong / developing / needs work) and give one concrete thing to improve next session.
   i. Update `problem.md` frontmatter: set `status`, `time_complexity`, `space_complexity`, `last_practiced`
5. **Review flow**: Re-present an existing problem. For **standard** and **deep** effort levels, have the user walk through the 6-step framework again from memory — this tests whether they internalized the approach, not just the solution. For **quick**, just have them re-solve and discuss. After re-solving, quiz on complexity and alternative approaches.
6. **Hints**: When the user asks for help, **first normalize the struggle**: "Getting stuck here is normal — this is exactly the kind of moment an interviewer wants to see you work through." Then anchor hints to the 6-step framework:
   - First, identify which step they're on. If they jumped straight to coding, gently redirect: "Let's back up — can you walk through an example first?"
   - **Steps 1–3 hints:** Help them refine their understanding. Ask leading questions about constraints or edge cases they haven't considered.
   - **Step 4 hints:** Nudge toward the pattern first ("What if you used a hash map here?"), then the key insight, then a more concrete approach. Don't jump to the full algorithm.
   - **Step 5 hints:** Point them back to their examples from Step 3. "What did you do by hand for input [2,7,11]? Can you translate that to code?"
   - **Step 6 hints:** If tests fail, ask them to trace through their code with the failing input before revealing the bug.

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
   - Built-in Big O: "What's the time complexity of `Array.prototype.sort()` in V8?" or "You're calling `.includes()` inside a loop — what's the overall complexity?" (Periodically quiz on the cost of JS/TS built-in operations — see `${CLAUDE_SKILL_DIR}/references/clarifying_questions.md` for the Big O reference table.)
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

**Difficulty calibration**: Scores should reflect understanding relative to the problem's difficulty. Needing 2 hints on a hard problem might still be a 6 (solid understanding of a challenging concept). Needing 2 hints on an easy problem is more like a 4 (the pattern should have been obvious). Apply the same scale, but factor in what was reasonable to expect given the difficulty.

## Sync Mode

Triggered by "sync" intent (e.g., `/sync-dsa`).

1. `cd ~/dsa-a-day`
2. `git add -A && git commit -m "Practice session <date>"`
3. Check if remote exists: `git remote -v`
4. If no remote, offer to create: `gh repo create dsa-a-day --private --source=. --push`
5. If remote exists: `git push`

---

## Clarifying Questions Checklist

See `${CLAUDE_SKILL_DIR}/references/clarifying_questions.md` for the full 7-question checklist with filtering rationale and TS/JS built-in Big O reference table. Read this file at the start of any practice session (standard or deep) to inform Step 2 guidance and deep mode feedback scoring.

Summary of the 7 questions: (1) Can I use built-ins? (2) What's the input type? (3) Will input always be valid? (4) Does it fit in memory? (5) Is it sorted? (6) Can I modify in place? (7) How do we define optimal?
