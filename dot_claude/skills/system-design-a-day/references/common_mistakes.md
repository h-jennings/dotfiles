# Common Mistakes

The 6 pitfalls the playbook calls out. Read this at the start of deep-mode
sessions, and surface the relevant ones during feedback if observed.

---

## 1. Jumping into answers too quickly

"Answering the wrong question well is worse than answering the right question
poorly." Skipping phase R leads to solving a scope the interviewer didn't
ask for.

**Fix**: mandatory 3+ clarifying questions before any design work.

## 2. Unstructured approach

Talking randomly makes the response feel disorganized, even when the ideas
are good. The interviewer can't track coverage.

**Fix**: announce RADIO phase transitions out loud. "OK, moving into phase A —
let me sketch the components."

## 3. Insisting on one "best" solution

Real problems have multiple valid designs. Inflexibility signals poor
engineering judgment.

**Fix**: for every major decision, name the alternative before picking one.
"I'd use REST over GraphQL here because ___, but GraphQL would win if ___."

## 4. Remaining silent throughout

Interviews are collaborative. Silent thinking prevents the interviewer from
following the reasoning and kills opportunities for mid-course correction.

**Fix**: narrate. Even "I'm thinking about whether this needs real-time or
if polling is fine" is better than dead air.

## 5. Deep-diving into irrelevant components

Spending 15 minutes on URL routing for a collaborative doc wastes time that
should go to OT / CRDT. Focus on what makes the product unique.

**Fix**: at the start of phase O, explicitly state which axes matter most for
this product and why. Skip the others with one sentence.

## 6. Using unexplained buzzwords

"We'd use Virtual DOM for perf" without elaboration sounds superficial and
sets up a follow-up that exposes the gap.

**Fix**: never drop a term without a one-sentence explanation of the
mechanism. If you can't explain it, don't invoke it.
