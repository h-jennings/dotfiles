# Craft Tracks

The six tracks are a *menu*, not a roadmap. There is no finish line and no
prescribed order — maintenance mode is about staying fluent, so the goal is a
fresh mixed bag. Rotate tracks across sessions; let curiosity and review-urgency
pick the day's exercise.

Each track lists **what it trains**, **when to reach for it**, and a **seed bank**
of concrete exercise ideas. The seed banks are starting points — invent new ones
freely, and prefer ideas that connect to the user's real front-end/TypeScript work.

- [build — Breakable Toys](#build--breakable-toys)
- [refactor — Refactor & Critique](#refactor--refactor--critique)
- [fluency — Language & Type Fluency](#fluency--language--type-fluency)
- [testing — Testing Craft](#testing--testing-craft)
- [debugging — Debugging Drills](#debugging--debugging-drills)
- [async — Async & Concurrency](#async--async--concurrency)

---

## build — Breakable Toys

**Trains:** Constructing things from scratch. Owning an implementation end to end,
making real design choices, and producing a small working artifact. The single
best antidote to atrophy.

**Reach for it when:** You want to build something satisfying and self-contained,
or you've been gluing libraries together at work and want to remember how the
primitives actually work.

**Seed bank:** debounce · throttle · LRU cache · event emitter / pub-sub ·
finite state machine · memoize (with custom key) · retry-with-backoff ·
deepEqual · curry / pipe / compose · a tiny query-string parser · a priority
queue · a circular buffer · a minimal signal/observable · a small CSV parser ·
a `groupBy` from scratch · a tiny templating function.

---

## refactor — Refactor & Critique

**Trains:** Judgment. Reading working-but-messy code and making it clearer
without changing behavior — and being able to *name* why the new version is
better. Sharpens the editor's eye, not just the author's.

**Reach for it when:** You want to practice taste and restraint, or to rehearse
the code-review instincts you use on real PRs.

**The drill:** `before.ts` holds smelly-but-correct code; `before.test.ts` pins
its behavior and must stay green. Refactor `before.ts` until it reads well, tests
still passing. For pure code-review reps, skip the rewrite and write the critique
(smells found, severity, suggested fix) into `brief.md`.

**Seed bank:** untangle nested pricing conditionals · extract a god-function into
named helpers · replace boolean flag args with an options object · replace
mutation with immutable transforms · name magic numbers / extract constants ·
collapse duplicated branches · callback pyramid → async/await · imperative loop →
declarative pipeline (and recognize when *not* to) · model invalid states out of
existence with a discriminated union · simplify a gnarly boolean expression ·
inject a hard-coded clock/dependency.

---

## fluency — Language & Type Fluency

**Trains:** Speed and idiom in the everyday vocabulary — JS/TS expressions you
should be able to write without thinking, and the TypeScript type system as a
tool you reach for confidently.

**Reach for it when:** You want a short, low-stakes warm-up, or you noticed
yourself fumbling a language feature recently.

**Two flavors:** *value drills* (run via `drills.test.ts`) and *type puzzles*
(compile-time `Expect<Equal<...>>` asserts, validated by `pnpm typecheck`).

**Seed bank:** array reshaping (map/filter/reduce/flatMap) · `groupBy` /
`partition` / `indexBy` · immutable update patterns · multi-key comparator chains ·
Map/Set fluency · `Object.entries` transforms · optional-chaining & nullish
idioms · constrained generics & `infer` · mapped & conditional types · rebuild
`Pick` / `Omit` / `Partial` from scratch · `as const` & literal inference ·
template-literal types · discriminated-union narrowing · `Intl` number/date
formatting.

---

## testing — Testing Craft

**Trains:** Test *design* — choosing what to verify, covering edges and error
paths, and writing tests that document behavior and read as a spec.

**Reach for it when:** You want to practice the skill independently of writing the
code it tests — a skill that quietly decays because at work the code already
exists.

**The drill:** `subject.ts` holds a correct implementation; `subject.test.ts` is
empty. Write the tests: happy path, edge cases, error/invalid input, boundaries.
Then judge your own coverage — what's still untested, what's over-tested.

**Seed bank:** test a pure function's boundaries · test a stateful class · cover
error paths · table-driven / parametrized cases · test code with an injected
clock · characterization tests for legacy code · decide what *not* to test ·
arrange-act-assert discipline · test a parser's edge cases · think in invariants
(property-style) · mock a dependency cleanly.

---

## debugging — Debugging Drills

**Trains:** The diagnostic loop — read a failure, form a hypothesis, locate the
cause, fix it, and explain the root cause. Deliberate practice of something
usually only done under pressure.

**Reach for it when:** You want to sharpen reading-for-bugs, or to study a class
of bug you keep getting burned by.

**The drill:** `buggy.ts` has one planted bug; `buggy.test.ts` is red because of
it. Run it, read the failure, hypothesize, fix `buggy.ts` to green — then state
the root cause in one sentence.

**Seed bank:** off-by-one in pagination · closure-over-loop-variable · floating-
point comparison · mutation/aliasing via shared reference · missing `await`
ordering bug · `this`-binding bug · operator-precedence / short-circuit bug ·
stale closure in a hook · NaN propagation · timezone/date arithmetic bug ·
comparator returning a boolean instead of a number · shallow copy where deep was
needed · lost update from a race condition.

---

## async — Async & Concurrency

**Trains:** Reasoning about time and concurrency — promises, cancellation, race
conditions, ordering, and parallelism. This is where the user's React instincts
(race-condition-safe data fetching, debounced search) generalize into
framework-agnostic craft.

**Reach for it when:** You want to drill the hardest-to-reason-about code, or
revisit an async footgun.

**The drill:** `starter.ts` + `starter.test.ts`. For timing, use vitest fake
timers (`vi.useFakeTimers()`, `vi.advanceTimersByTimeAsync`). For ordering/race
exercises, resolve promises in a deliberate order and assert on what was observed.

**Seed bank:** cancel a stale request (AbortController / ignore-flag) · debounce
an async search · retry with exponential backoff · run N promises with a
concurrency limit (pool) · `Promise.all` vs `allSettled` semantics · sequential
vs parallel orchestration · timeout wrapper that races a promise · a simple async
queue · single-flight (dedupe in-flight requests) · handle partial failure ·
poll with backoff and a stop condition · preserve order when responses arrive out
of order.
