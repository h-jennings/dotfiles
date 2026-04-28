# Evaluation Rubric

The 6 axes used to grade a front-end system design session. Adapted from the
GreatFrontend playbook's evaluation criteria. Use this to score deep-mode
sessions and fill the `rubric_scores` frontmatter field.

Each axis is scored **strong / developing / needs work**. Don't give a blanket
score — be specific about what was missing.

---

## 1. Problem Exploration

*Did the candidate understand and scope the problem?*

- **Strong**: Asked 5+ filtering questions that each narrowed the design
  space. Distinguished functional vs. non-functional requirements. Stated
  in-scope/out-of-scope explicitly. Paraphrased the problem back before
  designing.
- **Developing**: Asked 2–3 questions but missed one or two that clearly
  mattered for this problem. Mixed functional and non-functional without
  labeling them. Scope was implicit.
- **Needs work**: Jumped straight to designing. Didn't ask about users,
  scale, platforms, or performance targets. Solved the wrong problem or a
  scope larger than the time allowed.

## 2. Architecture

*Did the candidate produce a coherent high-level design?*

- **Strong**: Drew a diagram with clear boundaries. Each component owned one
  responsibility. Data flow was unidirectional and named. Pushed computation
  to the right side of the client/server line with justification.
- **Developing**: Produced components but responsibilities blurred together,
  or the diagram was hand-wavy. Data flow direction was implicit.
- **Needs work**: No diagram. Components and data fetching mixed together.
  The design couldn't be re-explained without the candidate re-deriving it.

## 3. Technical Proficiency

*Did the candidate demonstrate depth of front-end knowledge?*

- **Strong**: Used specific terminology correctly (hydration, SSR, CSR,
  virtualization, CRDT, IndexedDB, service worker, etc.). Knew the
  tradeoffs, not just the names. Picked techniques that matched the
  problem.
- **Developing**: Used the right terms but couldn't always explain the
  underlying mechanism. Suggested techniques that fit the genre but
  weren't the best fit for *this* problem's constraints.
- **Needs work**: Unexplained buzzwords ("we'd use Virtual DOM for perf"
  without elaboration). Techniques from the wrong era or domain. Gaps on
  fundamentals that should be automatic at this level.

## 4. Exploration & Tradeoffs

*Did the candidate present multiple approaches and reason about tradeoffs?*

- **Strong**: For every major decision, named the alternative and explained
  why this one won given the requirements. Acknowledged that the decision
  could go the other way under different constraints.
- **Developing**: Mentioned alternatives in a few places but presented the
  chosen approach as the obviously-correct one elsewhere.
- **Needs work**: Single-solution thinking. "We'd use X" with no alternative
  considered. Insisted on one "best" answer when the problem has multiple
  valid designs.

## 5. Product & UX Sense

*Did the design feel user-aware, not just technically sound?*

- **Strong**: Called out loading states, error states, empty states,
  optimistic updates. Considered accessibility and mobile from the start,
  not as afterthoughts. Anticipated failure modes (slow network, API
  errors, conflicting edits).
- **Developing**: Mentioned UX concerns when prompted but didn't volunteer
  them. Treated a11y / i18n as a footnote.
- **Needs work**: Designed purely as a data-pipeline exercise. No loading
  or error states. A11y absent. Assumed the happy path only.

## 6. Communication & Collaboration

*Did the candidate think out loud and engage the interviewer?*

- **Strong**: Narrated reasoning consistently. Paused at phase boundaries
  to check alignment. Took interviewer feedback and adjusted. Used the
  whiteboard / diagram as a shared artifact, not private notes.
- **Developing**: Went silent during some phases. Took feedback but
  sometimes defended the original design instead of incorporating the new
  information.
- **Needs work**: Long silences. Jumped around between phases. Ignored or
  argued with interviewer prompts. Couldn't re-summarize the design when
  asked.

---

## Aggregate scoring

When writing the `understanding_score` (1–10) to frontmatter, roll up the
six axes:

- **9–10**: Strong on all 6 axes.
- **7–8**: Strong on 4+, developing on the rest.
- **5–6**: Mostly developing, at least 2 strong areas.
- **3–4**: Mostly developing or weak, significant gaps.
- **1–2**: Needs work across most axes — re-teach the problem before retest.

Always record the per-axis scores in `rubric_scores` frontmatter — the
aggregate loses information. Format:

```yaml
rubric_scores:
  problem_exploration: strong
  architecture: developing
  technical_proficiency: strong
  tradeoffs: developing
  product_ux: needs work
  communication: strong
```

## One concrete thing to improve

Every deep-mode debrief closes with one actionable thing to work on next
session. Don't give three. Pick the weakest axis and name a specific
behavior change ("next session, before you start phase A, sketch the
component diagram on paper first — don't think in prose").
