#!/usr/bin/env python3
"""
Create a new Craft exercise: a brief + track-specific starter files.

Usage:
    python create_exercise.py "Debounce" --track build --patterns "breakable-toys,practice"
    python create_exercise.py "Untangle the cart total" --track refactor
    python create_exercise.py "Array reshaping drills" --track fluency --topics "arrays,reduce"
    python create_exercise.py "Test the rate limiter" --track testing
    python create_exercise.py "The off-by-one pagination bug" --track debugging
    python create_exercise.py "Cancel the stale request" --track async --topics "race-conditions"

Tracks (the file set varies by track):
    build      brief.md + starter.ts + <slug>.test.ts   build a utility from scratch
    refactor   brief.md + before.ts  + before.test.ts    clean up smelly code, keep tests green
    fluency    brief.md + drills.ts  + drills.test.ts     idiomatic JS/TS + type-puzzle reps
    testing    brief.md + subject.ts + subject.test.ts    write thorough tests for given code
    debugging  brief.md + buggy.ts   + buggy.test.ts      diagnose & fix a planted bug
    async      brief.md + starter.ts + starter.test.ts    promises, cancellation, race conditions
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path

TRACKS = ("build", "refactor", "fluency", "testing", "debugging", "async")


def get_repo_path():
    return Path.home() / "craft-a-day"


def slugify(text):
    out = []
    for ch in text.lower():
        if ch.isalnum():
            out.append(ch)
        elif ch in (" ", "_", "-"):
            out.append("-")
    slug = "".join(out)
    while "--" in slug:
        slug = slug.replace("--", "-")
    return slug.strip("-")


def fn_name(slug):
    parts = [p for p in slug.split("-") if p]
    if not parts:
        return "solve"
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


def brief_md(title, track, patterns_yaml, topics_yaml, date_str):
    return f"""---
title: {title}
track: {track}
patterns: {patterns_yaml}
topics: {topics_yaml}
status: unsolved
confidence: null
last_practiced: null
last_reviewed: null
created: {date_str}
last_updated: {date_str}
---

# {title}

## Brief

[TODO: One-paragraph description of the exercise. Conversational. State what to
build / fix / drill, and why it's worth the reps.]

## Requirements

[TODO: The concrete acceptance criteria — what "done" looks like. Keep it small.]

## Stretch

[TODO: Optional harder variation for a deep session, or "—".]

---

## Reflection

[One or two lines after solving: what was sharp, what was rusty, what to remember.]

## Q&A

[Questions and answers recorded during the session.]

## Review History

[Spaced-repetition re-solves recorded here.]
"""


def build_files(title, slug):
    fn = fn_name(slug)
    starter = f"""/**
 * {title}
 *
 * [TODO: short doc — signature and behavior]
 */
export function {fn}() {{
  // TODO: implement
}}
"""
    test = f"""import {{ describe, it, expect }} from "vitest";
import {{ {fn} }} from "./starter";

describe("{title}", () => {{
  it.todo("handles the basic case");
  it.todo("handles edge cases");
}});
"""
    return {"starter.ts": starter, f"{slug}.test.ts": test}


def refactor_files(title, slug):
    before = f"""/**
 * {title} — code to refactor.
 *
 * [TODO: paste the working-but-smelly implementation here. It must pass
 *  before.test.ts as-is. The goal of the session is to improve its clarity,
 *  naming, and structure WITHOUT changing behavior (keep the tests green).]
 */

// TODO: smelly implementation goes here
export function placeholder() {{
  return null;
}}
"""
    test = f"""import {{ describe, it, expect }} from "vitest";
// Behavior-pinning tests: these must stay GREEN through the refactor.
import {{ placeholder }} from "./before";

describe("{title} — behavior is preserved", () => {{
  it.todo("pins the existing behavior so the refactor can't break it");
}});
"""
    return {"before.ts": before, "before.test.ts": test}


def fluency_files(title, slug):
    drills = f"""/**
 * {title} — fluency drills.
 *
 * Small, idiomatic reps. For TYPE puzzles, use the compile-time asserts below
 * and run `pnpm typecheck` — a wrong type makes tsc fail. For value drills, use
 * drills.test.ts and run `pnpm vitest run`.
 */

// --- Type-puzzle helpers (delete if this is a value-only drill) ---
type Expect<T extends true> = T;
type Equal<A, B> =
  (<G>() => G extends A ? 1 : 2) extends (<G>() => G extends B ? 1 : 2) ? true : false;

// Example:
// type _t1 = Expect<Equal<MyType, ExpectedType>>;

// --- Value drills ---
// TODO: export the functions the drills exercise.
export {{}};
"""
    test = f"""import {{ describe, it, expect }} from "vitest";
// import {{ /* drills */ }} from "./drills";

describe("{title}", () => {{
  it.todo("drill 1");
  it.todo("drill 2");
}});
"""
    return {"drills.ts": drills, "drills.test.ts": test}


def testing_files(title, slug):
    fn = fn_name(slug)
    subject = f"""/**
 * {title} — subject under test.
 *
 * [TODO: a CORRECT, working implementation goes here. The exercise is to write
 *  thorough tests for it in subject.test.ts: happy path, edge cases, error
 *  cases, boundaries. Practicing test DESIGN, not implementation.]
 */
export function {fn}() {{
  // TODO: working implementation to be tested
}}
"""
    test = f"""import {{ describe, it, expect }} from "vitest";
import {{ {fn} }} from "./subject";

// Write the tests. Aim for: the happy path, edge cases, error/invalid input,
// and boundaries. Name each case for the behavior it pins.
describe("{title}", () => {{
  it.todo("happy path");
  it.todo("edge cases");
  it.todo("error / invalid input");
}});
"""
    return {"subject.ts": subject, "subject.test.ts": test}


def debugging_files(title, slug):
    fn = fn_name(slug)
    buggy = f"""/**
 * {title} — buggy code.
 *
 * [TODO: a plausible implementation with ONE planted bug. buggy.test.ts should
 *  fail because of it. The exercise: run the test, read the failure, form a
 *  hypothesis, locate the bug, fix it — then explain the root cause.]
 */
export function {fn}() {{
  // TODO: implementation containing a planted bug
}}
"""
    test = f"""import {{ describe, it, expect }} from "vitest";
import {{ {fn} }} from "./buggy";

// This test encodes the CORRECT expected behavior. It should be RED until the
// bug in buggy.ts is found and fixed.
describe("{title}", () => {{
  it.todo("documents the correct behavior the bug violates");
}});
"""
    return {"buggy.ts": buggy, "buggy.test.ts": test}


def async_files(title, slug):
    fn = fn_name(slug)
    starter = f"""/**
 * {title}
 *
 * [TODO: short doc. Async/concurrency reps — promises, cancellation,
 *  race conditions, parallelism, retry/backoff, debounce/throttle timing.]
 */
export async function {fn}() {{
  // TODO: implement
}}
"""
    test = f"""import {{ describe, it, expect, vi }} from "vitest";
import {{ {fn} }} from "./starter";

// For timing-based exercises, reach for fake timers:
//   vi.useFakeTimers();  ...  await vi.advanceTimersByTimeAsync(ms);
// For ordering/race exercises, resolve promises in a deliberate order and
// assert on what was observed.
describe("{title}", () => {{
  it.todo("behaves correctly under the async conditions");
}});
"""
    return {"starter.ts": starter, "starter.test.ts": test}


TRACK_BUILDERS = {
    "build": build_files,
    "refactor": refactor_files,
    "fluency": fluency_files,
    "testing": testing_files,
    "debugging": debugging_files,
    "async": async_files,
}


def create_exercise(title, track="build", patterns=None, topics=None):
    """Create a new exercise directory with track-specific scaffolded files."""
    if track not in TRACKS:
        raise ValueError(f"Unknown track '{track}'. Choose one of: {', '.join(TRACKS)}")

    repo_path = get_repo_path()
    exercises_dir = repo_path / "exercises"
    exercises_dir.mkdir(parents=True, exist_ok=True)

    slug = slugify(title)
    exercise_dir = exercises_dir / slug

    if exercise_dir.exists():
        print(f"Exercise directory already exists: {exercise_dir}")
        return exercise_dir

    exercise_dir.mkdir()

    date_str = datetime.now().strftime("%d-%m-%Y")
    patterns_list = [p.strip() for p in patterns.split(",")] if patterns else []
    topics_list = [t.strip() for t in topics.split(",")] if topics else []
    patterns_yaml = "[" + ", ".join(patterns_list) + "]"
    topics_yaml = "[" + ", ".join(topics_list) + "]"

    (exercise_dir / "brief.md").write_text(
        brief_md(title, track, patterns_yaml, topics_yaml, date_str)
    )
    for name, content in TRACK_BUILDERS[track](title, slug).items():
        (exercise_dir / name).write_text(content)

    return exercise_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new Craft exercise")
    parser.add_argument("title", help="Exercise title (e.g., 'Debounce')")
    parser.add_argument(
        "--track",
        choices=TRACKS,
        default="build",
        help="Exercise track (default: build)",
    )
    parser.add_argument(
        "--patterns",
        default=None,
        help="Comma-separated apprenticeship patterns (e.g., 'breakable-toys,practice')",
    )
    parser.add_argument(
        "--topics",
        default=None,
        help="Comma-separated topics (e.g., 'arrays,reduce')",
    )

    args = parser.parse_args()

    try:
        exercise_dir = create_exercise(
            args.title, track=args.track, patterns=args.patterns, topics=args.topics
        )
        print(f"Created {args.track} exercise: {exercise_dir}")
        return 0
    except Exception as e:
        print(f"Error creating exercise: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
