#!/usr/bin/env python3
"""
Create a new Craft concept tutorial with frontmatter, runnable examples, and an exercise.

Usage:
    python create_concept.py "Discriminated Unions" --concepts "typescript,unions"
    python create_concept.py "The Reducer Pattern" --concepts "state,immutability"
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path


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


def create_concept(title, concepts=None):
    """Create a new concept directory with scaffolded files."""
    repo_path = get_repo_path()
    concepts_dir = repo_path / "concepts"
    concepts_dir.mkdir(parents=True, exist_ok=True)

    slug = slugify(title)
    concept_dir = concepts_dir / slug

    if concept_dir.exists():
        print(f"Concept directory already exists: {concept_dir}")
        return concept_dir

    concept_dir.mkdir()

    date_str = datetime.now().strftime("%d-%m-%Y")
    concepts_list = [c.strip() for c in concepts.split(",")] if concepts else [slug]
    concepts_yaml = "[" + ", ".join(concepts_list) + "]"

    concept_md = f"""---
title: {title}
concepts: {concepts_yaml}
related_exercises: []
confidence: null
last_reviewed: null
prerequisites: []
created: {date_str}
last_updated: {date_str}
---

# {title}

## Why This Matters

[TODO: What everyday problem does this solve? When does reaching for it make code clearer?]

## How It Works

[TODO: Build the mental model — diagrams, analogies, a step-by-step walkthrough.]

## In Practice

[TODO: The core details. Reference examples.ts for runnable code.]

## When To Reach For It (and when not to)

[TODO: Decision framework vs. the alternatives. The tradeoff, named honestly.]

## Where This Shows Up

[TODO: Real spots in day-to-day front-end / TypeScript work where this pays off.]

---

## Q&A

[Questions and answers recorded during learning.]

## Review History

[Spaced-repetition re-solves recorded here.]
"""

    examples_ts = f"""/**
 * {title} — Runnable Examples
 *
 * Run with: pnpm tsx concepts/{slug}/examples.ts
 *
 * Each example demonstrates a key aspect of the concept.
 */

// Example 1: Basic usage
// [TODO: Fill in with demonstrative code]

console.log("=== {title} Examples ===");
console.log("TODO: Add examples");
"""

    exercise_ts = f"""/**
 * {title} — Practice Exercise
 *
 * Complete the exercise below to cement understanding.
 * Run with: pnpm tsx concepts/{slug}/exercise.ts
 */

// Exercise: [TODO: Description]
export function exercise() {{
  // TODO: implement
}}

// console.log(exercise());
"""

    (concept_dir / "concept.md").write_text(concept_md)
    (concept_dir / "examples.ts").write_text(examples_ts)
    (concept_dir / "exercise.ts").write_text(exercise_ts)

    return concept_dir


def main():
    parser = argparse.ArgumentParser(description="Create a new Craft concept tutorial")
    parser.add_argument("title", help="Concept title (e.g., 'Discriminated Unions')")
    parser.add_argument(
        "--concepts",
        help="Comma-separated concept tags (e.g., 'typescript,unions')",
        default=None,
    )

    args = parser.parse_args()

    try:
        concept_dir = create_concept(args.title, concepts=args.concepts)
        print(f"Created concept: {concept_dir}")
        return 0
    except Exception as e:
        print(f"Error creating concept: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
