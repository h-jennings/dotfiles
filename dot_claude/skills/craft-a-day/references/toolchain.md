# Toolchain

The `~/craft-a-day/` repo is a plain pnpm + TypeScript + vitest workspace. Keep
it light; everything runs in Node (no browser/jsdom).

## First-time install

```bash
cd ~/craft-a-day && pnpm install
```

## Running things

```bash
pnpm vitest run                         # all tests
pnpm vitest run exercises/<slug>        # one exercise's tests
pnpm vitest watch exercises/<slug>      # watch mode while iterating
pnpm tsx exercises/<slug>/starter.ts    # run a TS file directly (e.g. a console scratch)
pnpm tsx concepts/<slug>/examples.ts    # run a concept's runnable examples
pnpm typecheck                          # tsc --noEmit — REQUIRED to validate type puzzles
```

Vitest has `globals: true`, so `describe` / `it` / `expect` / `vi` are available
without imports (the scaffolds still import them explicitly for clarity).

## Type puzzles (fluency track)

Type-level exercises assert at compile time and are checked by `pnpm typecheck`,
**not** vitest. The scaffold includes the helpers:

```ts
type Expect<T extends true> = T;
type Equal<A, B> =
  (<G>() => G extends A ? 1 : 2) extends (<G>() => G extends B ? 1 : 2) ? true : false;

type _t1 = Expect<Equal<MyResult, Expected>>;   // tsc errors if the types differ
```

A passing puzzle is one where `pnpm typecheck` is clean. To prove a puzzle is
real, temporarily break the expected type and confirm tsc goes red.

## Async timing (async track)

Use vitest fake timers instead of real waits:

```ts
vi.useFakeTimers();
const p = doThingAfter(1000);
await vi.advanceTimersByTimeAsync(1000);
expect(await p).toBe(...);
vi.useRealTimers();
```

For race/ordering exercises, control resolution order explicitly (resolve
deferred promises in a chosen sequence) and assert on what was observed, rather
than relying on wall-clock timing.

## The reference solution

After the user solves, add the worked "common solution" alongside their work as
`solution.ts` (or a `## Reference solution` code block in `brief.md`). Keep it as
something to *study* — idiomatic and commented — not just a correct answer. (This
matches the user's standing preference to always add a common solution.)
